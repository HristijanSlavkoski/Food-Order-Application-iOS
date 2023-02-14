//
//  Order.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class Order: Codable {
    var userUUID: String
    var companyUUID: String
    var companyName: String
    var managerUUID: String
    var deliveryToHome: Bool
    var location: CustomLocationClass
    var foodOrderArrayList: [FoodOrder]
    var comment: String
    var totalPrice: Double
    var isOrderTaken: Bool
    var timestampWhenOrderWillBeFinishedInMillis: Int64
    
    init(userUUID: String, companyUUID: String, companyName: String, managerUUID: String, deliveryToHome: Bool, location: CustomLocationClass, foodOrderArrayList: [FoodOrder], comment: String, totalPrice: Double, isOrderTaken: Bool, timestampWhenOrderWillBeFinishedInMillis: Int64) {
        self.userUUID = userUUID
        self.companyUUID = companyUUID
        self.companyName = companyName
        self.managerUUID = managerUUID
        self.deliveryToHome = deliveryToHome
        self.location = location
        self.foodOrderArrayList = foodOrderArrayList
        self.comment = comment
        self.totalPrice = totalPrice
        self.isOrderTaken = isOrderTaken
        self.timestampWhenOrderWillBeFinishedInMillis = timestampWhenOrderWillBeFinishedInMillis
    }
}
