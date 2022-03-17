//
//  UIImageView+FactoryExtension.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 14/03/22.
//

import UIKit

extension UIImageView {
    static func makeRounded(mode: UIView.ContentMode = .scaleAspectFill, radius: CGFloat = 16.0, backgroundColor: UIColor = .descriptionColor) -> UIImageView{
        let image = UIImageView()
        image.contentMode = mode
        image.clipsToBounds = true
        image.layer.cornerRadius = radius
        image.backgroundColor = backgroundColor
        return image
    }
}
