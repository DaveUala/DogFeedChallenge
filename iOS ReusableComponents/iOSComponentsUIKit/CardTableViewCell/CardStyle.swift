//
//  CardStyle.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import UIKit

public struct CardStyle {
    public let titleColor: UIColor
    public let descriptionColor: UIColor
    public let footerColor: UIColor
    public let backgroundColor: UIColor
    public let contentBackgroundColor: UIColor

    public init(titleColor: UIColor, descriptionColor: UIColor, footerColor: UIColor, backgroundColor: UIColor, contentBackgroundColor: UIColor) {
        self.titleColor = titleColor
        self.descriptionColor = descriptionColor
        self.footerColor = footerColor
        self.backgroundColor = backgroundColor
        self.contentBackgroundColor = contentBackgroundColor
    }
}

public extension CardStyle {
    static let `default`: CardStyle =
        .init(titleColor: .titleColor,
              descriptionColor: .descriptionColor,
              footerColor: .titleColor,
              backgroundColor: .backgroundColor,
              contentBackgroundColor: .contentBackgroundColor)
}

