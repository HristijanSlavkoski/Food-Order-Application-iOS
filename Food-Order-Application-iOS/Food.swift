//
//  Food.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class Food: Codable {
    var name: String
    var price: Double

    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}
