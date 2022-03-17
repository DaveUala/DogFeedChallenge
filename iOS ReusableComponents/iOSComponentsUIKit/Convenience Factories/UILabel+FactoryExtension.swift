//
//  UILabel+FactoryExtension.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 14/03/22.
//

import UIKit

public extension UILabel {
    static func makeBold(size: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size)
        return label
    }

    static func makeWithUnlimitedLines(size: CGFloat) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: size)
        return label
    }
}
