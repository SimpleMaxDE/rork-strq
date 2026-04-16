import SwiftUI

struct ExerciseLibraryView: View {
    let vm: AppViewModel
    @State private var searchText: String = ""
    @State private var selectedWorld: TrainingWorld?
    @State private var selectedMuscle: MuscleGroup?
    @State private var selectedDifficulty: ExerciseDifficulty?
    @State private var showFilters: Bool = false
    @State private var bodyweightOnly: Bool = false
    @State private var jointFriendlyOnly: Bool = false
    @State private var favoritesOnly: Bool = false
    @State private var selectedExercise: Exercise?
    @State private var appeared: Bool = false
    @State private var browseMode: BrowseMode = .all

    private let library = ExerciseLibrary.shared

    private var filteredExercises: [Exercise] {
        var results: [Exercise]
        if !searchText.isEmpty {
            results = library.search(searchText)
        } else {
            results = library.filtered(
                muscle: selectedMuscle,
                world: selectedWorld,
                difficulty: selectedDifficulty,
                bodyweightOnly: bodyweightOnly,
                jointFriendly: jointFriendlyOnly
            )
        }
        if favoritesOnly {
            results = results.filter { vm.favoriteExerciseIds.contains($0.id) }
        }
        return results
    }

    private var groupedExercises: [(MuscleGroup, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.primaryMuscle }
        return MuscleGroup.allCases.compactMap { muscle in
            guard let exercises = grouped[muscle], !exercises.isEmpty else { return nil }
            return (muscle, exercises)
        }
    }

    private var featuredExercises: [Exercise] {
        let featured = ["barbell-bench-press", "pull-up", "barbell-squat", "romanian-deadlift", "overhead-press", "barbell-row"]
        return featured.compactMap { library.exercise(byId: $0) }
    }

    private var progressingExercises: [Exercise] {
        vm.progressionStates
            .filter { $0.plateauStatus == .progressing }
            .prefix(4)
            .compactMap { library.exercise(byId: $0.exerciseId) }
    }

    private var stalledExercises: [Exercise] {
        vm.progressionStates
            .filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .stalling }
            .prefix(3)
            .compactMap { library.exercise(byId: $0.exerciseId) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if searchText.isEmpty && selectedWorld == nil && selectedMuscle == nil && !favoritesOnly {
                    libraryHero
                    if !progressingExercises.isEmpty {
                        progressingSection
                    }
                    if !stalledExercises.isEmpty {
                        needsAttentionSection
                    }
                    exerciseFamiliesSection
                    featuredSection
                }

                trainingWorldsSection
                    .padding(.top, searchText.isEmpty && selectedWorld == nil && selectedMuscle == nil && !favoritesOnly ? 8 : 0)
                filterChips
                exerciseCountBar
                exerciseList
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .searchable(text: $searchText, prompt: "Search exercises, muscles, equipment...")
        .navigationTitle("Exercise Library")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedExercise) { exercise in
            NavigationStack {
                ExerciseDetailView(exercise: exercise, vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFilters) {
            filterSheet
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var libraryHero: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical.fill")
                            .font(.caption)
                            .foregroundStyle(STRQBrand.steel)
                        Text("CURATED LIBRARY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQBrand.steel)
                            .tracking(0.5)
                    }

                    Text("\(library.exercises.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    + Text(" exercises")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    libraryStatChip("\(TrainingWorld.allCases.count) worlds", icon: "globe", color: .blue)
                    libraryStatChip("\(MuscleGroup.allCases.count) muscles", icon: "figure.strengthtraining.traditional", color: .green)
                    if !vm.favoriteExerciseIds.isEmpty {
                        libraryStatChip("\(vm.favoriteExerciseIds.count) favorites", icon: "heart.fill", color: .red)
                    }
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [STRQBrand.steel.opacity(0.06), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    private func libraryStatChip(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(STRQBrand.steel)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(STRQBrand.steel.opacity(0.1), in: Capsule())
        .overlay(Capsule().strokeBorder(STRQBrand.steel.opacity(0.06), lineWidth: 0.5))
    }

    private var progressingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("PROGRESSING")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(progressingExercises) { exercise in
                        let progression = vm.progressionStates.first(where: { $0.exerciseId == exercise.id })
                        Button {
                            selectedExercise = exercise
                        } label: {
                            compactExerciseCard(exercise, badge: progression?.recommendedStrategy.displayName, badgeColor: .green)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 16)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    @ViewBuilder
    private var needsAttentionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("NEEDS ATTENTION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(stalledExercises) { exercise in
                        let progression = vm.progressionStates.first(where: { $0.exerciseId == exercise.id })
                        Button {
                            selectedExercise = exercise
                        } label: {
                            compactExerciseCard(exercise, badge: progression?.plateauStatus.displayName, badgeColor: colorFor(progression?.plateauStatus.colorName ?? "orange"))
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 12)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)
    }

    private func compactExerciseCard(_ exercise: Exercise, badge: String?, badgeColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: exercise.primaryMuscle.symbolName)
                    .font(.title3)
                    .foregroundStyle(STRQBrand.steel)
                    .frame(width: 36, height: 36)
                    .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 10))
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(badgeColor.opacity(0.12), in: Capsule())
                }
            }

            Text(exercise.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(exercise.primaryMuscle.displayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(width: 150)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("ESSENTIAL EXERCISES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(featuredExercises) { exercise in
                        Button {
                            selectedExercise = exercise
                        } label: {
                            featuredCard(exercise)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 12)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func featuredCard(_ exercise: Exercise) -> some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [colorForWorld(exercise.trainingWorlds.first ?? .gymStrength).opacity(0.15), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 70)

                Image(systemName: exercise.primaryMuscle.symbolName)
                    .font(.system(size: 28))
                    .foregroundStyle(colorForWorld(exercise.trainingWorlds.first ?? .gymStrength))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(exercise.primaryMuscle.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(STRQBrand.steel)
                    Circle().fill(Color(.separator)).frame(width: 3, height: 3)
                    Text(exercise.category.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < difficultyLevel(exercise.difficulty) ? diffColor(exercise.difficulty) : Color(.separator))
                            .frame(width: 5, height: 5)
                    }
                    Text(exercise.difficulty.displayName)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 156)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }

    private var exerciseFamiliesSection: some View {
        let familyService = ExerciseFamilyService.shared
        let topFamilies = Array(familyService.families.prefix(10))

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("EXERCISE FAMILIES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Text("\(familyService.families.count)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(topFamilies, id: \.id) { family in
                        let standard = library.exercise(byId: family.standardExerciseId)
                        Button {
                            if let ex = standard {
                                selectedExercise = ex
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: family.icon)
                                        .font(.title3)
                                        .foregroundStyle(STRQBrand.steel)
                                        .frame(width: 36, height: 36)
                                        .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 10))
                                    Spacer()
                                    Text("\(family.memberIds.count)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(STRQBrand.steel)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(STRQBrand.steel.opacity(0.1), in: Capsule())
                                }

                                Text(family.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Text(family.primaryMuscles.prefix(2).map { $0.displayName }.joined(separator: ", "))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                Text(family.description)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(width: 160)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 12)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    private var trainingWorldsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("TRAINING WORLDS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(TrainingWorld.allCases) { world in
                        let isSelected = selectedWorld == world
                        let worldColor = colorForWorld(world)
                        Button {
                            withAnimation(.snappy) {
                                selectedWorld = selectedWorld == world ? nil : world
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: world.symbolName)
                                    .font(.title3)
                                    .foregroundStyle(isSelected ? .white : worldColor)
                                    .frame(width: 40, height: 40)
                                    .background(isSelected ? worldColor : worldColor.opacity(0.1), in: Circle())
                                Text(world.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(isSelected ? worldColor : .secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                Text("\(library.exercises(forWorld: world).count)")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(width: 80, height: 90)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.top, 12)
    }

    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Button {
                    showFilters = true
                } label: {
                    let hasActiveFilters = bodyweightOnly || jointFriendlyOnly || selectedDifficulty != nil
                    HStack(spacing: 5) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 12))
                        Text("Filters")
                            .font(.subheadline.weight(.medium))
                        if hasActiveFilters {
                            Circle()
                                .fill(STRQBrand.steel)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                }

                ForEach(MuscleRegion.allCases) { region in
                    Menu {
                        ForEach(region.muscles) { muscle in
                            Button(muscle.displayName) {
                                selectedMuscle = selectedMuscle == muscle ? nil : muscle
                            }
                        }
                    } label: {
                        let isActive = selectedMuscle.map { region.muscles.contains($0) } ?? false
                        Text(region.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isActive ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? STRQBrand.steel : Color(.secondarySystemGroupedBackground), in: Capsule())
                            .overlay(Capsule().strokeBorder(isActive ? Color.clear : STRQBrand.cardBorder, lineWidth: 1))
                    }
                }

                Button {
                    withAnimation { favoritesOnly.toggle() }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: favoritesOnly ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                        Text("Favorites")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(favoritesOnly ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(favoritesOnly ? STRQBrand.steel : Color(.secondarySystemGroupedBackground), in: Capsule())
                    .overlay(Capsule().strokeBorder(favoritesOnly ? Color.clear : STRQBrand.cardBorder, lineWidth: 1))
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.top, 12)
    }

    private var exerciseCountBar: some View {
        HStack {
            Text("\(filteredExercises.count) exercises")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if selectedMuscle != nil || selectedWorld != nil || bodyweightOnly || jointFriendlyOnly || favoritesOnly {
                Button("Clear All") {
                    withAnimation {
                        selectedMuscle = nil
                        selectedWorld = nil
                        selectedDifficulty = nil
                        bodyweightOnly = false
                        jointFriendlyOnly = false
                        favoritesOnly = false
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(STRQBrand.steel)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private var exerciseList: some View {
        LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedExercises, id: \.0) { muscle, exercises in
                Section {
                    LazyVStack(spacing: 6) {
                        ForEach(exercises) { exercise in
                            ExerciseCard(
                                exercise: exercise,
                                isFavorite: vm.favoriteExerciseIds.contains(exercise.id),
                                progression: vm.progressionStates.first(where: { $0.exerciseId == exercise.id })
                            ) {
                                selectedExercise = exercise
                            } onFavorite: {
                                vm.toggleFavorite(exercise.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } header: {
                    HStack(spacing: 8) {
                        Image(systemName: muscle.symbolName)
                            .font(.subheadline)
                            .foregroundStyle(STRQBrand.steel)
                        Text(muscle.displayName)
                            .font(.subheadline.weight(.semibold))
                        Text("\(exercises.count)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }
            }
        }
        .padding(.top, 4)
    }

    private var filterSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    filterSection("Difficulty") {
                        HStack(spacing: 8) {
                            ForEach(ExerciseDifficulty.allCases) { diff in
                                filterChip(diff.displayName, selected: selectedDifficulty == diff, color: diffColor(diff)) {
                                    selectedDifficulty = selectedDifficulty == diff ? nil : diff
                                }
                            }
                        }
                    }

                    filterSection("Attributes") {
                        VStack(spacing: 8) {
                            Toggle("Bodyweight Only", isOn: $bodyweightOnly)
                                .tint(STRQBrand.steel)
                            Toggle("Joint-Friendly Only", isOn: $jointFriendlyOnly)
                                .tint(STRQBrand.steel)
                        }
                    }

                    filterSection("Muscle Group") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(MuscleGroup.allCases) { muscle in
                                filterChip(muscle.displayName, selected: selectedMuscle == muscle, color: STRQBrand.steel) {
                                    selectedMuscle = selectedMuscle == muscle ? nil : muscle
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showFilters = false }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func filterSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    @ViewBuilder
    private func filterChip(_ title: String, selected: Bool, color: Color = STRQBrand.steel, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? color : Color(.secondarySystemGroupedBackground), in: Capsule())
        }
    }

    private func colorForWorld(_ world: TrainingWorld) -> Color {
        STRQBrand.steel
    }

    private func diffColor(_ diff: ExerciseDifficulty) -> Color {
        switch diff {
        case .beginner: .green
        case .intermediate: STRQBrand.steel
        case .advanced: .red
        }
    }

    private func difficultyLevel(_ diff: ExerciseDifficulty) -> Int {
        switch diff {
        case .beginner: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "orange": return STRQBrand.steel
        case "yellow": return .yellow
        case "green": return .green
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        default: return STRQBrand.steel
        }
    }
}

nonisolated enum BrowseMode: String, CaseIterable {
    case all
    case byMuscle
    case byWorld
}

struct ExerciseCard: View {
    let exercise: Exercise
    let isFavorite: Bool
    var progression: ExerciseProgressionState?
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(exerciseAccentColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: exercise.primaryMuscle.symbolName)
                        .font(.title3)
                        .foregroundStyle(exerciseAccentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        if let p = progression {
                            Image(systemName: p.plateauStatus.icon)
                                .font(.system(size: 9))
                                .foregroundStyle(plateauColor(p.plateauStatus))
                        }
                    }

                    HStack(spacing: 6) {
                        Text(exercise.primaryMuscle.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(STRQBrand.steel)

                        if exercise.category == .compound {
                            Text("Compound")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(STRQBrand.steel)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(STRQBrand.steel.opacity(0.1), in: Capsule())
                        }

                        if !exercise.equipment.filter({ $0 != .none }).isEmpty {
                            Text(exercise.equipment.filter { $0 != .none }.first?.displayName ?? "")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(i < diffLevel ? diffColor : Color(.separator))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.body)
                        .foregroundStyle(isFavorite ? STRQBrand.steel : Color.secondary.opacity(0.4))
                }
                .buttonStyle(.plain)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary.opacity(0.3))
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var exerciseAccentColor: Color {
        STRQBrand.steel
    }

    private var diffLevel: Int {
        switch exercise.difficulty {
        case .beginner: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }

    private var diffColor: Color {
        switch exercise.difficulty {
        case .beginner: .green
        case .intermediate: STRQBrand.steel
        case .advanced: .red
        }
    }

    private func plateauColor(_ status: PlateauStatus) -> Color {
        switch status {
        case .progressing: .green
        case .stalling: .yellow
        case .plateaued: STRQBrand.steel
        case .regressing: .red
        }
    }
}
