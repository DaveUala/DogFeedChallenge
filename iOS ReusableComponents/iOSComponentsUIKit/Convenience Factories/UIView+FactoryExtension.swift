//
//  UIView+FactoryExtension.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 14/03/22.
//

import UIKit

extension UIView {
    static func make(corners: CACornerMask, with radius: CGFloat = 16.0) -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.maskedCorners = corners
        view.layer.cornerRadius = radius

        return view
    }
}
