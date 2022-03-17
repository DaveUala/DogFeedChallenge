//
//  SharedTestHelpers.swift
//  David Castro Konfio Challenge
//
//  Created by David Castro Cisneros on 15/03/22.
//

import Foundation

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyNSError() -> NSError {
    return NSError(domain: "TEST", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
