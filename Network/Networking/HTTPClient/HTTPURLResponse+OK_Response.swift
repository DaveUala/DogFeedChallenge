//
//  HTTPURLResponse+OK_Response.swift
//  Networking
//
//  Created by David Castro Cisneros on 08/03/22.
//

import Foundation

extension HTTPURLResponse {
    static let OK_200 = 200
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
