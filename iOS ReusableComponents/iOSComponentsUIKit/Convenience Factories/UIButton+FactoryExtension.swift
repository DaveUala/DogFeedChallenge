//
//  UIButton+FactoryExtension.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit

extension UIButton {
    static func makeRefreshButton() -> UIButton {
        let button = UIButton()
        let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
        let boldRefresh = UIImage(systemName: "gobackward", withConfiguration: boldConfig)
        button.setImage(boldRefresh, for: .normal)
        button.tintColor = .white
        
        return button
    }
}
