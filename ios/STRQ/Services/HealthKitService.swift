import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

@Observable
@MainActor
final class HealthKitService {
    static let shared = HealthKitService()

    enum AuthState: String, Sendable {
        case unknown
        case unavailable
        case notDetermined
        case authorized
        case denied
    }

    private(set) var authState: AuthState = .unknown
    private(set) var lastSyncDate: Date?

    #if canImport(HealthKit)
    private let store: HKHealthStore? = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    #endif

    var isAvailable: Bool {
        #if canImport(HealthKit)
        return HKHealthStore.isHealthDataAvailable()
        #else
        return false
        #endif
    }

    init() {
        if !isAvailable {
            authState = .unavailable
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        #if canImport(HealthKit)
        guard let store else {
            authState = .unavailable
            return false
        }
        let read: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        let write: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.workoutType()
        ]
        do {
            try await store.requestAuthorization(toShare: write, read: read)
            // bodyMass write auth is the closest proxy we can inspect
            let status = store.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .bodyMass)!)
            switch status {
            case .sharingAuthorized: authState = .authorized
            case .sharingDenied: authState = .denied
            case .notDetermined: authState = .notDetermined
            @unknown default: authState = .notDetermined
            }
            return authState == .authorized
        } catch {
            authState = .denied
            return false
        }
        #else
        return false
        #endif
    }

    // MARK: - Body Weight

    func saveBodyWeight(kg: Double, date: Date = Date()) async {
        #if canImport(HealthKit)
        guard let store, authState == .authorized else { return }
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        let quantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        try? await store.save(sample)
        lastSyncDate = Date()
        #endif
    }

    func readLatestBodyWeight() async -> (kg: Double, date: Date)? {
        #if canImport(HealthKit)
        guard let store, authState == .authorized else { return nil }
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return nil }
        return await withCheckedContinuation { (continuation: CheckedContinuation<(Double, Date)?, Never>) in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil); return
                }
                let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: (kg, sample.endDate))
            }
            store.execute(q)
        }
        #else
        return nil
        #endif
    }

    // MARK: - Sleep

    func readRecentSleepHours(days: Int = 1) async -> Double? {
        #if canImport(HealthKit)
        guard let store, authState == .authorized else { return nil }
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -days, to: end) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return await withCheckedContinuation { (continuation: CheckedContinuation<Double?, Never>) in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                    continuation.resume(returning: nil); return
                }
                let asleepValues: Set<Int> = {
                    var set: Set<Int> = [HKCategoryValueSleepAnalysis.asleep.rawValue]
                    set.insert(HKCategoryValueSleepAnalysis.asleepCore.rawValue)
                    set.insert(HKCategoryValueSleepAnalysis.asleepDeep.rawValue)
                    set.insert(HKCategoryValueSleepAnalysis.asleepREM.rawValue)
                    set.insert(HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue)
                    return set
                }()
                let seconds = samples.reduce(0.0) { acc, s in
                    asleepValues.contains(s.value) ? acc + s.endDate.timeIntervalSince(s.startDate) : acc
                }
                continuation.resume(returning: seconds > 0 ? seconds / 3600.0 : nil)
            }
            store.execute(q)
        }
        #else
        return nil
        #endif
    }

    // MARK: - Workout

    func saveWorkout(start: Date, end: Date, totalVolumeKg: Double) async {
        #if canImport(HealthKit)
        guard let store, authState == .authorized else { return }
        let duration = max(60, end.timeIntervalSince(start))
        // Energy estimate: traditional strength ~5 kcal/min as a calm default.
        let kcal = HKQuantity(unit: .kilocalorie(), doubleValue: duration / 60.0 * 5.0)
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        do {
            try await builder.beginCollection(at: start)
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let sample = HKQuantitySample(type: energyType, quantity: kcal, start: start, end: end)
            try await builder.addSamples([sample])
            try await builder.endCollection(at: end)
            _ = try await builder.finishWorkout()
            lastSyncDate = Date()
        } catch {
            // graceful fallback — silent
        }
        #endif
    }
}

extension HKQuantity: @unchecked @retroactive Sendable {}
