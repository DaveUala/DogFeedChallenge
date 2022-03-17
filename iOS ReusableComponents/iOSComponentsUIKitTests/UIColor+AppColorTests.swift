//
//  UIColor+AppColorTests.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import XCTest

final class AppColorIntegrityTests: XCTestCase {

    /// This test makes sure that it is safe to force unwrap through the code
    func test_integrity_onCustomColor() throws {
        let _: Set<UIColor> = [
            .titleColor,
            .backgroundColor,
            .contentBackgroundColor,
            .descriptionColor
        ]
    }
}
