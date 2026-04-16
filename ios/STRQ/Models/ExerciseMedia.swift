import Foundation

nonisolated enum ExerciseMediaType: String, Codable, Sendable {
    case staticImage
    case lottie
    case rive
    case video
    case gif
    case sfSymbol
}

nonisolated struct ExerciseMedia: Codable, Sendable {
    let mediaType: ExerciseMediaType
    let assetName: String?
    let assetURL: String?
    let previewImageName: String?
    let thumbnailName: String?
    let movementFamily: MovementFamily?
    let hasFrontView: Bool
    let hasBackView: Bool

    init(
        mediaType: ExerciseMediaType = .sfSymbol,
        assetName: String? = nil,
        assetURL: String? = nil,
        previewImageName: String? = nil,
        thumbnailName: String? = nil,
        movementFamily: MovementFamily? = nil,
        hasFrontView: Bool = true,
        hasBackView: Bool = false
    ) {
        self.mediaType = mediaType
        self.assetName = assetName
        self.assetURL = assetURL
        self.previewImageName = previewImageName
        self.thumbnailName = thumbnailName
        self.movementFamily = movementFamily
        self.hasFrontView = hasFrontView
        self.hasBackView = hasBackView
    }
}

nonisolated enum MovementFamily: String, Codable, Sendable {
    case press
    case pull
    case squat
    case hinge
    case carry
    case lunge
    case rotation
    case isolation
    case plank
    case stretch
    case cardio
}
