import CoreText
import Foundation

enum STRQFontRegistrar {
    private static let fontExtensions = ["ttf", "otf"]
    private static let fontSubdirectories: [String?] = [
        STRQDesignSystem.workSansFontResourceSubdirectory,
        "Fonts",
        nil
    ]

    private static let registrationLock = NSLock()
    private static var didRegisterBundledFonts = false

    static func registerBundledFonts(bundle: Bundle = .main) {
        registrationLock.lock()
        guard !didRegisterBundledFonts else {
            registrationLock.unlock()
            return
        }
        didRegisterBundledFonts = true
        registrationLock.unlock()

        let fontURLs = bundledFontURLs(bundle: bundle)

        guard !fontURLs.isEmpty else {
            log("No bundled Work Sans font files found; using system typography fallback.")
            return
        }

        logMissingRequiredFonts(from: fontURLs)

        for fontURL in fontURLs {
            registerFont(at: fontURL)
        }
    }

    static func hasBundledFontFiles(bundle: Bundle = .main) -> Bool {
        !bundledFontURLs(bundle: bundle).isEmpty
    }

    static func bundledFontFileNames(bundle: Bundle = .main) -> [String] {
        bundledFontURLs(bundle: bundle).map(\.lastPathComponent)
    }

    private static func bundledFontURLs(bundle: Bundle) -> [URL] {
        var urls: [URL] = []
        var seenPaths = Set<String>()

        for resourceName in STRQDesignSystem.workSansFontResourceNames {
            for fontExtension in fontExtensions {
                for subdirectory in fontSubdirectories {
                    guard let url = bundle.url(
                        forResource: resourceName,
                        withExtension: fontExtension,
                        subdirectory: subdirectory
                    ) else { continue }

                    let path = url.standardizedFileURL.path
                    guard seenPaths.insert(path).inserted else { continue }
                    urls.append(url)
                }
            }
        }

        return urls
    }

    private static func registerFont(at url: URL) {
        var registrationError: Unmanaged<CFError>?
        let didRegister = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &registrationError)

        guard !didRegister else {
            return
        }

        guard let error = registrationError?.takeRetainedValue() else {
            log("Unable to register \(url.lastPathComponent): unknown CoreText error.")
            return
        }

        log("Unable to register \(url.lastPathComponent): \((error as Error).localizedDescription)")
    }

    private static func logMissingRequiredFonts(from fontURLs: [URL]) {
        let bundledResourceNames = Set(
            fontURLs.map { $0.deletingPathExtension().lastPathComponent }
        )
        let missingRequiredFonts = STRQDesignSystem.workSansRequiredFontResourceNames.filter {
            !bundledResourceNames.contains($0)
        }

        guard !missingRequiredFonts.isEmpty else {
            return
        }

        log("Missing bundled Work Sans weights: \(missingRequiredFonts.joined(separator: ", ")).")
    }

    private static func log(_ message: String) {
        print("[STRQ] \(message)")
    }
}
