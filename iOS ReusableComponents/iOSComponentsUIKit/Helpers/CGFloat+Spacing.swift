//
//  CGFloat+Spacing.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 14/03/22.
//

import CoreGraphics

public extension CGFloat {
    static var smallSpace: CGFloat { return 8 }
    static var defaultSpace: CGFloat { return 16 }
    static var mediumSpace: CGFloat { return 24 }
    static var largeSpace: CGFloat { return 32 }
    static var extraLargeSpace: CGFloat { return 40 }
    var negativeValue: CGFloat { return -(self) }
}
