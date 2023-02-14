//
//  CustomLocationClass.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import Foundation

class CustomLocationClass: Codable {
    var longitude: Double
    var latitude: Double

    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

