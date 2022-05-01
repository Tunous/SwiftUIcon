//
//  IconGenerator.swift
//
//  Created by Zac White.
//  Copyright © 2020 Velos Mobile LLC / https://velosmobile.com / All rights reserved.
//

import Foundation
import SwiftUI

#if os(macOS)

public enum Idiom: String {
    case iPad = "ipad"
    case iPhone = "iphone"
    case mac = "mac"
    case marketing = "ios-marketing"
}

/// An IconSet based around a View for a given set of idioms
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct IconSet<Content: View>: Encodable {

    /// The View to use when generating the IconSet
    let content: Content

    /// The Icon instances to use when generating metadata
    let images: [Icon]

    /// Creates an IconSet for the given idioms based on the passed in View
    /// - Parameter idioms: A Set of idioms to use when generating the IconSet
    /// - Parameter view: The View to base the generated icon off of
    public init(idioms: Set<Idiom>, view: Content) {
        images = [
            .init(idiom: .iPad, size: CGSize(width: 20, height: 20), scale: .oneX, placeholder: !idioms.contains(.iPad)),
            .init(idiom: .iPad, size: CGSize(width: 20, height: 20), scale: .twoX, placeholder: !idioms.contains(.iPad)),

            .init(idiom: .iPad, size: CGSize(width: 29, height: 29), scale: .oneX, placeholder: !idioms.contains(.iPad)),
            .init(idiom: .iPad, size: CGSize(width: 29, height: 29), scale: .twoX, placeholder: !idioms.contains(.iPad)),

            .init(idiom: .iPad, size: CGSize(width: 40, height: 40), scale: .oneX, placeholder: !idioms.contains(.iPad)),
            .init(idiom: .iPad, size: CGSize(width: 40, height: 40), scale: .twoX, placeholder: !idioms.contains(.iPad)),

            .init(idiom: .iPad, size: CGSize(width: 76, height: 76), scale: .oneX, placeholder: !idioms.contains(.iPad)),
            .init(idiom: .iPad, size: CGSize(width: 76, height: 76), scale: .twoX, placeholder: !idioms.contains(.iPad)),

            .init(idiom: .iPad, size: CGSize(width: 83.5, height: 83.5), scale: .twoX, placeholder: !idioms.contains(.iPad)),

            .init(idiom: .iPhone, size: CGSize(width: 20, height: 20), scale: .twoX, placeholder: !idioms.contains(.iPhone)),
            .init(idiom: .iPhone, size: CGSize(width: 20, height: 20), scale: .threeX, placeholder: !idioms.contains(.iPhone)),

            .init(idiom: .iPhone, size: CGSize(width: 29, height: 29), scale: .twoX, placeholder: !idioms.contains(.iPhone)),
            .init(idiom: .iPhone, size: CGSize(width: 29, height: 29), scale: .threeX, placeholder: !idioms.contains(.iPhone)),

            .init(idiom: .iPhone, size: CGSize(width: 40, height: 40), scale: .twoX, placeholder: !idioms.contains(.iPhone)),
            .init(idiom: .iPhone, size: CGSize(width: 40, height: 40), scale: .threeX, placeholder: !idioms.contains(.iPhone)),

            .init(idiom: .iPhone, size: CGSize(width: 60, height: 60), scale: .twoX, placeholder: !idioms.contains(.iPhone)),
            .init(idiom: .iPhone, size: CGSize(width: 60, height: 60), scale: .threeX, placeholder: !idioms.contains(.iPhone)),

            .init(idiom: .mac, size: CGSize(width: 16, height: 16), scale: .oneX, placeholder: !idioms.contains(.mac)),
            .init(idiom: .mac, size: CGSize(width: 16, height: 16), scale: .twoX, placeholder: !idioms.contains(.mac)),

            .init(idiom: .mac, size: CGSize(width: 32, height: 32), scale: .oneX, placeholder: !idioms.contains(.mac)),
            .init(idiom: .mac, size: CGSize(width: 32, height: 32), scale: .twoX, placeholder: !idioms.contains(.mac)),

            .init(idiom: .mac, size: CGSize(width: 128, height: 128), scale: .oneX, placeholder: !idioms.contains(.mac)),
            .init(idiom: .mac, size: CGSize(width: 128, height: 128), scale: .twoX, placeholder: !idioms.contains(.mac)),

            .init(idiom: .mac, size: CGSize(width: 256, height: 256), scale: .oneX, placeholder: !idioms.contains(.mac)),
            .init(idiom: .mac, size: CGSize(width: 256, height: 256), scale: .twoX, placeholder: !idioms.contains(.mac)),

            .init(idiom: .mac, size: CGSize(width: 512, height: 512), scale: .oneX, placeholder: !idioms.contains(.mac)),
            .init(idiom: .mac, size: CGSize(width: 512, height: 512), scale: .twoX, placeholder: !idioms.contains(.mac)),

            .init(idiom: .marketing, size: CGSize(width: 1024, height: 1024), scale: .oneX, placeholder: !idioms.contains(.marketing))
        ]

        content = view
    }

    enum Scale: String {
        case oneX = "1x"
        case twoX = "2x"
        case threeX = "3x"

        var multiplier: CGFloat {
            switch self {
            case .oneX: return 1
            case .twoX: return 2
            case .threeX: return 3
            }
        }
    }

    struct Icon: Hashable, Encodable {
        let idiom: Idiom
        let size: CGSize
        let scale: Scale
        let placeholder: Bool

        fileprivate var filename: String? {
            guard !placeholder else { return nil }

            var fullName = "AppIcon"
            fullName.append("-\(idiom.rawValue)")
            fullName.append("-\(size.sizeString)")

            if scale != .oneX {
                fullName.append("@\(scale.rawValue)")
            }

            fullName.append(".png")

            return fullName
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(idiom)
            hasher.combine(scale)
            hasher.combine(size.width)
            hasher.combine(size.height)
        }

        enum CodingKeys: CodingKey {
            case idiom, size, scale, filename
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(idiom.rawValue, forKey: .idiom)
            try container.encode(scale.rawValue, forKey: .scale)
            try container.encode(size.sizeString, forKey: .size)
            try container.encodeIfPresent(filename, forKey: .filename)
        }
    }

    private enum CodingKeys: CodingKey {
        case images
    }

    /// Writes the AppIcon.appiconset to the given URL for the xcassets folder. This will overwrite any existing AppIcon.appiconset that exists and will fail if any
    /// of the icons can't be generated or written to the proper locations.
    /// - Parameter url: The file URL that points to the `Assets.xcassets` folder in the project directory
    public func write(to url: URL) throws {

        // create the folder "AppIcon.appiconset"
        let iconSetUrl = url.appendingPathComponent("AppIcon.appiconset", isDirectory: true)

        // remove any existing icon set
        try? FileManager.default.removeItem(at: iconSetUrl)

        // create all the directories needed to start writing the image files
        try FileManager.default.createDirectory(at: iconSetUrl, withIntermediateDirectories: true, attributes: nil)

        for image in images {
            if !image.placeholder, let filename = image.filename {
                try content.writeImage(
                    to: iconSetUrl.appendingPathComponent(filename),
                    size: image.size * image.scale.multiplier,
                    roundedFrame: image.idiom == .mac
                )
            }
        }

        // encode the manifest
        let manifest = try JSONEncoder().encode(self)

        // write the manifest to the `Contents.json` files
        try manifest.write(to: iconSetUrl.appendingPathComponent("Contents.json"))
    }
}

extension CGSize {

    /// A size string suitible for putting into the size property of the Contents.json file. Ex. "83.5x83.5" or "76x76"
    var sizeString: String {
        var format: String = ""
        if width.distance(to: round(width)) < 0.001 {
            format.append("%.0f")
        } else {
            format.append("%.1f")
        }

        format.append("x")

        if height.distance(to: round(height)) < 0.001 {
            format.append("%.0f")
        } else {
            format.append("%.1f")
        }

        return String(format: format, width, height)
    }

    /// Scales a size by the right-hand-side value
    /// - Parameter lhs: The size to scale
    /// - Parameter rhs: The factor to use when scaling the size
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

enum GenerationError: Error {
    case couldNotGetImageRep
    case couldNotGeneratePNG
    case couldNotWriteImage
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Generates an image from the current View
    /// - Parameter url: The file url to write the image
    /// - Parameter size: The size of the image to generate
    /// - Parameter roundedFrame: Whether the image should be clipped to macOS like rounded frame or not
    public func writeImage(to url: URL, size: CGSize, roundedFrame: Bool = false) throws {

        // works around FB9488576 by scaling up the view, and then scaling down the rasterized image
        let upscaledSize = CGSize(width: size.width * 4.0, height: size.height * 4.0)

        let wrapper = roundedFrame
            ? NSHostingView(rootView: self.frameIcon(dimension: min(upscaledSize.width, upscaledSize.height) * 0.8))
            : NSHostingView(rootView: self)
        wrapper.frame = CGRect(origin: .zero, size: upscaledSize)

        guard let bitmapRepresentation = wrapper.bitmapImageRepForCachingDisplay(in: wrapper.bounds) else {
            throw GenerationError.couldNotGetImageRep
        }

        bitmapRepresentation.size = wrapper.bounds.size
        wrapper.cacheDisplay(in: wrapper.bounds, to: bitmapRepresentation)

        guard let image = bitmapRepresentation.cgImage else {
            throw GenerationError.couldNotGeneratePNG
        }

        // generate a CGContext and draw the image into it at the desired size
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: image.bitmapInfo.rawValue
        )

        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else {
            throw GenerationError.couldNotGeneratePNG
        }

        // write the image to disk
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else {
            throw GenerationError.couldNotWriteImage
        }

        CGImageDestinationAddImage(destination, scaledImage, nil)
        if !CGImageDestinationFinalize(destination) {
            throw GenerationError.couldNotWriteImage
        }
    }
}

#endif
