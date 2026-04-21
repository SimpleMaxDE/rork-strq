import SwiftUI
import UIKit
import ImageIO
import UniformTypeIdentifiers

/// Decoded animated-GIF content ready to hand to UIKit.
/// - For static images (or non-GIF data), `image` is a plain `UIImage` and
///   `isAnimated` is false.
/// - For animated GIFs, `image` is a `UIImage.animatedImage(with:duration:)`
///   with frame delays baked into the total duration (UIKit handles the
///   animation when rendered inside a UIImageView).
struct DecodedRemoteImage {
    let image: UIImage
    let isAnimated: Bool
    let byteCount: Int
}

enum RemoteGIFDecoder {
    /// Decodes GIF data into an animated `UIImage` via ImageIO. Returns a
    /// static `UIImage` if the data isn't a recognised GIF or has one frame.
    /// Returns nil only if the data cannot be decoded at all.
    static func decode(_ data: Data) -> DecodedRemoteImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            if let img = UIImage(data: data) {
                return DecodedRemoteImage(image: img, isAnimated: false, byteCount: data.count)
            }
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let typeID = CGImageSourceGetType(source) as String? ?? ""
        let isGIF = typeID == (UTType.gif.identifier)
        guard isGIF, count > 1 else {
            if let img = UIImage(data: data) {
                return DecodedRemoteImage(image: img, isAnimated: false, byteCount: data.count)
            }
            return nil
        }
        var frames: [UIImage] = []
        frames.reserveCapacity(count)
        var totalDuration: Double = 0
        for i in 0..<count {
            guard let cg = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            frames.append(UIImage(cgImage: cg))
            totalDuration += Self.frameDelay(source: source, index: i)
        }
        if totalDuration < 0.02 { totalDuration = Double(count) * 0.1 }
        guard let animated = UIImage.animatedImage(with: frames, duration: totalDuration) else {
            if let img = UIImage(data: data) {
                return DecodedRemoteImage(image: img, isAnimated: false, byteCount: data.count)
            }
            return nil
        }
        return DecodedRemoteImage(image: animated, isAnimated: true, byteCount: data.count)
    }

    private static func frameDelay(source: CGImageSource, index: Int) -> Double {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }
        if let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
            return unclamped
        }
        if let clamped = gif[kCGImagePropertyGIFDelayTime] as? Double, clamped > 0 {
            return clamped
        }
        return 0.1
    }
}

/// UIKit-backed view that actually animates animated `UIImage` frames.
/// SwiftUI's `Image(uiImage:)` does NOT animate animated UIImages, so we
/// bridge through `UIImageView` for correct GIF playback.
struct AnimatedGIFView: UIViewRepresentable {
    let image: UIImage
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.contentMode = contentMode
        view.clipsToBounds = true
        view.image = image
        view.isUserInteractionEnabled = false
        if image.images != nil { view.startAnimating() }
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if uiView.image !== image {
            uiView.image = image
            if image.images != nil, !uiView.isAnimating {
                uiView.startAnimating()
            }
        }
        if uiView.contentMode != contentMode {
            uiView.contentMode = contentMode
        }
    }
}
