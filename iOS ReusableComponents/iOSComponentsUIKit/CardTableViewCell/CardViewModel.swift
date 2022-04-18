//
//  CardViewModel.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

public struct CardViewModel {
    public let title: String
    public let description: String
    public let other: String
    public let footer: String

    public init(title: String, description: String, other: String, footer: String) {
        self.title = title
        self.description = description
        self.other = other
        self.footer = footer
    }
}
