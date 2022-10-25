//
//  CustomNativeAccordionAdView.swift
//  Test GAM
//
//  Created by Sylvan Ash on 25/10/2022.
//  Copyright © 2022 Sylvan Ash. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class CustomNativeAccordionAdView: UIView {
    private var ad: GADCustomNativeAd?

    init?(ad: GADCustomNativeAd) {
        guard let image = ad.image(forKey: "image")?.image else {
            return nil
        }
        super.init(frame: .zero)
        setupSubviews(image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews(_ image: UIImage) {
        let image = resizeAdImage(image)
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: scaledMaxHeight),
        ])
    }

    private func resizeAdImage(_ image: UIImage) -> UIImage {
        var img = image
        var renderedSize = CGSize(width: scaledWidth, height: scaledMaxHeight)
        if !(image.size.equalTo(renderedSize) && image.scale == UIScreen.main.scale) {
            img = img.resized(to: renderedSize) ?? img
        }
        return img
    }

    private var nativeWidth: CGFloat {
        return ViewHelper.panelWidth * UIScreen.main.scale
    }

    private var scaledWidth: CGFloat {
        return nativeWidth / UIScreen.main.scale
    }

    private var scaledMaxHeight: CGFloat {
        return nativeWidth / UIScreen.main.scale
    }
}

private class ViewHelper: NSObject {
    static let maxPanelWidth: CGFloat = 504

    // Only use this if you're going to re-check the value on every appWillChangeSize call
    static var panelWidth: CGFloat {
        return min(windowWidth, maxPanelWidth)
    }

    static var windowWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
}

private extension UIImage {
    /**
     Returns a resized image using the specified size and quality.

     - parameter size: The size to use when resizing the image.
     - parameter quality: The desired quality. The default value is `CGInterpolationQuality.high`
     - returns: A resize image if one can be created. Otherwise, nil.
     */
    func resized(to size: CGSize, using quality: CGInterpolationQuality = .high) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let cgImage = cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context =  UIGraphicsGetCurrentContext()

        context?.interpolationQuality = quality
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context?.concatenate(transform)

        context?.draw(cgImage, in: rect)
        guard let resizedCGImage = context?.makeImage() else { return nil }
        let image = UIImage(cgImage: resizedCGImage, scale: UIScreen.main.scale, orientation: imageOrientation)
        UIGraphicsEndImageContext()
        return image
    }
}
