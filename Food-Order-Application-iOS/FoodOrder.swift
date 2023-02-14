//
//  FoodOrder.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class FoodOrder: Codable {
    var name: String
    var priceForEach: Double
    var count: Int
    var totalPrice: Double

    init(name: String, priceForEach: Double, count: Int, totalPrice: Double) {
        self.name = name
        self.priceForEach = priceForEach
        self.count = count
        self.totalPrice = totalPrice
    }
}
