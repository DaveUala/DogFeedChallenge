//
//  UIColor+AppColors.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import UIKit

public extension UIColor {
    private static var bundle = Bundle(identifier: "konfioChallenge.iOSComponentsUIKit")

    static var backgroundColor =  UIColor(named: "backgroundColor", in: bundle, compatibleWith: nil)!
    static var titleColor =  UIColor(named: "titleColor", in: bundle, compatibleWith: nil)!
    static var descriptionColor =  UIColor(named: "descriptionColor", in: bundle, compatibleWith: nil)!
    static var contentBackgroundColor =  UIColor(named: "contentBackgroundColor", in: bundle, compatibleWith: nil)!

}
