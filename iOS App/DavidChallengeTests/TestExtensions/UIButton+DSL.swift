//
//  UIButton+DSL.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
