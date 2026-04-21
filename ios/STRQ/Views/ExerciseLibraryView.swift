import SwiftUI

struct ExerciseLibraryView: View {
    let vm: AppViewModel
    @State private var searchText: String = ""
    @State private var selectedWorld: TrainingWorld?
    @State private var selectedMuscle: MuscleGroup?
    @State private var selectedPattern: MovementPatternGroup?
    @State private var selectedDifficulty: ExerciseDifficulty?
    @State private var showFilters: Bool = false
    @State private var bodyweightOnly: Bool = false
    @State private var jointFriendlyOnly: Bool = false
    @State private var favoritesOnly: Bool = false
    @State private var selectedExercise: Exercise?
    @State private var appeared: Bool = false
    @State private var browseMode: BrowseMode = .all

    private let library = ExerciseLibrary.shared
    private let catalog = ExerciseCatalog.shared

    private var filteredExercises: [Exercise] {
        var results: [Exercise]
        if !searchText.isEmpty {
            results = catalog.search(searchText)
        } else if selectedMuscle == nil && selectedWorld == nil && selectedDifficulty == nil && !bodyweightOnly && !jointFriendlyOnly {
            results = catalog.all
        } else {
            results = library.filtered(
                muscle: selectedMuscle,
                world: selectedWorld,
                difficulty: selectedDifficulty,
                bodyweightOnly: bodyweightOnly,
                jointFriendly: jointFriendlyOnly
            )
        }
        if let pattern = selectedPattern {
            results = results.filter { pattern.contains($0.movementPattern) }
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
                    if !progressingExercises.isEmpty || !stalledExercises.isEmpty {
                        yourExercisesSection
                    }
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
        HStack(alignment: .center, spacing: 0) {
            libraryStatColumn(value: "\(catalog.all.count)", label: "Exercises")
            libraryDivider
            libraryStatColumn(value: "\(ExerciseFamilyService.shared.families.count)", label: "Families")
            libraryDivider
            libraryStatColumn(value: "\(MuscleGroup.allCases.count)", label: "Muscles")
            libraryDivider
            libraryStatColumn(value: "\(vm.favoriteExerciseIds.count)", label: "Favorites")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    @ViewBuilder
    private var yourExercisesSection: some View {
        let combined: [(Exercise, ExerciseProgressionState?)] =
            progressingExercises.prefix(3).map { ex in (ex, vm.progressionStates.first(where: { $0.exerciseId == ex.id })) }
            + stalledExercises.prefix(2).map { ex in (ex, vm.progressionStates.first(where: { $0.exerciseId == ex.id })) }

        if !combined.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text("YOUR EXERCISES")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color(.separator).opacity(0.4))
                        .frame(height: 0.5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)

                VStack(spacing: 0) {
                    ForEach(Array(combined.enumerated()), id: \.offset) { idx, pair in
                        yourExerciseRow(pair.0, progression: pair.1)
                        if idx < combined.count - 1 {
                            Rectangle()
                                .fill(Color(.separator).opacity(0.3))
                                .frame(height: 0.5)
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                .padding(.horizontal, 16)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func yourExerciseRow(_ exercise: Exercise, progression: ExerciseProgressionState?) -> some View {
        Button { selectedExercise = exercise } label: {
            HStack(spacing: 12) {
                ExerciseThumbnail(exercise: exercise, size: .small, cornerRadius: 9)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(exercise.primaryMuscle.displayName)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        if let p = progression {
                            Circle().fill(Color(.separator)).frame(width: 2, height: 2)
                            Text("\(p.sessionCount) sessions")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                Spacer()
                if let p = progression {
                    let c = plateauStatusColor(p.plateauStatus)
                    HStack(spacing: 4) {
                        Image(systemName: p.plateauStatus.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(p.plateauStatus.displayName)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(c)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(c.opacity(0.12), in: Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func plateauStatusColor(_ status: PlateauStatus) -> Color {
        switch status {
        case .progressing: STRQPalette.success
        case .stalling: STRQPalette.warning
        case .plateaued: STRQBrand.steel
        case .regressing: STRQPalette.danger
        }
    }

    private func libraryStatColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var libraryDivider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.6))
            .frame(width: 1, height: 28)
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
                        .buttonStyle(.strqPressable)
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

                Menu {
                    Button("All Patterns") { selectedPattern = nil }
                    Divider()
                    ForEach(MovementPatternGroup.allCases) { pattern in
                        Button {
                            selectedPattern = selectedPattern == pattern ? nil : pattern
                        } label: {
                            Label(pattern.displayName, systemImage: pattern.icon)
                        }
                    }
                } label: {
                    let isActive = selectedPattern != nil
                    HStack(spacing: 5) {
                        Image(systemName: selectedPattern?.icon ?? "arrow.triangle.swap")
                            .font(.system(size: 12))
                        Text(selectedPattern?.displayName ?? "Pattern")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(isActive ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(isActive ? STRQBrand.steel : Color(.secondarySystemGroupedBackground), in: Capsule())
                    .overlay(Capsule().strokeBorder(isActive ? Color.clear : STRQBrand.cardBorder, lineWidth: 1))
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
            if selectedMuscle != nil || selectedWorld != nil || selectedPattern != nil || bodyweightOnly || jointFriendlyOnly || favoritesOnly {
                Button("Clear All") {
                    withAnimation {
                        selectedMuscle = nil
                        selectedWorld = nil
                        selectedPattern = nil
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
        LazyVStack(spacing: 14, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedExercises, id: \.0) { muscle, exercises in
                Section {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCard(
                                exercise: exercise,
                                isFavorite: vm.favoriteExerciseIds.contains(exercise.id),
                                progression: vm.progressionStates.first(where: { $0.exerciseId == exercise.id })
                            ) {
                                selectedExercise = exercise
                            } onFavorite: {
                                vm.toggleFavorite(exercise.id)
                            }
                            if index < exercises.count - 1 {
                                Rectangle()
                                    .fill(Color(.separator).opacity(0.35))
                                    .frame(height: 0.5)
                                    .padding(.leading, 76)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                    .padding(.horizontal, 16)
                } header: {
                    HStack(spacing: 8) {
                        Image(systemName: muscle.symbolName)
                            .font(.caption)
                            .foregroundStyle(STRQBrand.steel)
                        Text(muscle.displayName.uppercased())
                            .font(.system(size: 11, weight: .black))
                            .tracking(1.0)
                            .foregroundStyle(.secondary)
                        Text("\(exercises.count)")
                            .font(.system(size: 10, weight: .bold).monospacedDigit())
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Rectangle()
                            .fill(Color(.separator).opacity(0.4))
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
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

nonisolated enum MovementPatternGroup: String, CaseIterable, Identifiable, Sendable {
    case push
    case pull
    case squat
    case hinge
    case lunge
    case carry
    case core
    case isolation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .push: "Push"
        case .pull: "Pull"
        case .squat: "Squat"
        case .hinge: "Hinge"
        case .lunge: "Lunge"
        case .carry: "Carry"
        case .core: "Core"
        case .isolation: "Isolation"
        }
    }

    var icon: String {
        switch self {
        case .push: "arrow.up.right"
        case .pull: "arrow.down.left"
        case .squat: "figure.strengthtraining.traditional"
        case .hinge: "figure.cooldown"
        case .lunge: "figure.walk"
        case .carry: "figure.walk.motion"
        case .core: "figure.core.training"
        case .isolation: "scope"
        }
    }

    func contains(_ pattern: MovementPattern) -> Bool {
        switch self {
        case .push: return pattern == .horizontalPush || pattern == .verticalPush
        case .pull: return pattern == .horizontalPull || pattern == .verticalPull
        case .squat: return pattern == .squat
        case .hinge: return pattern == .hipHinge
        case .lunge: return pattern == .lunge
        case .carry: return pattern == .carry
        case .core: return pattern == .isometric || pattern == .rotation || pattern == .antiRotation
        case .isolation: return pattern == .flexion || pattern == .extension_ || pattern == .abduction || pattern == .adduction
        }
    }
}

struct ExerciseCard: View {
    let exercise: Exercise
    let isFavorite: Bool
    var progression: ExerciseProgressionState?
    let onTap: () -> Void
    let onFavorite: () -> Void

    private var familyName: String? {
        ExerciseFamilyService.shared.family(forExercise: exercise.id)?.name
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ExerciseThumbnail(exercise: exercise, size: .small, cornerRadius: 9)

                VStack(alignment: .leading, spacing: 2) {
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

                    HStack(spacing: 5) {
                        Text(exercise.primaryMuscle.displayName)
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.secondary)

                        if let family = familyName {
                            Circle().fill(Color(.separator)).frame(width: 2, height: 2)
                            Text(family)
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Circle().fill(Color(.separator)).frame(width: 2, height: 2)
                            Text(exercise.category.displayName)
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        if let equip = exercise.equipment.first(where: { $0 != .none }) {
                            Circle().fill(Color(.separator)).frame(width: 2, height: 2)
                            Text(equip.displayName)
                                .font(.system(size: 10.5))
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer(minLength: 6)

                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i < diffLevel ? diffColor : Color(.separator).opacity(0.5))
                            .frame(width: 3, height: 8)
                    }
                }

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13))
                        .foregroundStyle(isFavorite ? STRQBrand.steel : Color.secondary.opacity(0.35))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
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
