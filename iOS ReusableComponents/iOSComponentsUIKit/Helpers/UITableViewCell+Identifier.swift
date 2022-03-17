//
//  UITableViewCell+Identifier.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 14/03/22.
//

import UIKit

public extension UITableViewCell {
    static var identifier: String { NSStringFromClass(self) }
}
