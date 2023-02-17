//
//  User.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class User: Codable {
    var email: String
    var role: Role

    init(email: String, role: Role) {
        self.email = email
        self.role = role
    }
}
