//
//  CompanyToBeSent.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/16/23.
//

import UIKit
import Foundation

class CompanyToBeSent: Codable {
    var company: Company
    var companyId: String

    init(company: Company, companyId: String) {
        self.company = company
        self.companyId = companyId
    }
}
