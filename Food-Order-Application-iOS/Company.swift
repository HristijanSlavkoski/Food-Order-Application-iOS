//
//  Company.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class Company: Codable {
    var name: String
    var imageUrl: String
    var category: CompanyCategory
    var location: CustomLocationClass
    var workingAtWeekends: Bool
    var workingAtNight: Bool
    var offersDelivery: Bool
    var foodArray: [Food]
    var managerUUID: String
    var approved: Bool

    init(name: String, imageUrl: String, category: CompanyCategory, location: CustomLocationClass, workingAtWeekends: Bool, workingAtNight: Bool, offersDelivery: Bool, foodArray: [Food], managerUUID: String, approved: Bool) {
        self.name = name
        self.imageUrl = imageUrl
        self.category = category
        self.location = location
        self.workingAtWeekends = workingAtWeekends
        self.workingAtNight = workingAtNight
        self.offersDelivery = offersDelivery
        self.foodArray = foodArray
        self.managerUUID = managerUUID
        self.approved = approved
    }
}

