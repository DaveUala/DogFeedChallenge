//
//  XCTestCase+Localization.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 14/03/22.
//

import XCTest

extension XCTestCase {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)

        if key == value {
            XCTFail("Missing value for given key")
        }

        return value
    }
}
