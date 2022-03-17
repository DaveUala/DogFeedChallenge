//
//  UIRefreshController+DSL.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
