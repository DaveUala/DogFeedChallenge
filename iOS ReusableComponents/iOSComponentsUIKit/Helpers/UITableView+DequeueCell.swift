//
//  UITableView+DequeueCell.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 17/03/22.
//

import UIKit

public extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        return dequeueReusableCell(withIdentifier: T.identifier) as! T
    }
}
