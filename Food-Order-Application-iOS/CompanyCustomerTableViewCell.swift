//
//  CompanyCustomerTableViewCell.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/16/23.
//

import UIKit

class CompanyCustomerTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var workingNow: UILabel!
    @IBOutlet weak var offersDelivery: UILabel!
    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    var buttonAction: ((CompanyCustomerTableViewCell) -> Void)?
    
    
    @objc func didTapButton() {
        buttonAction?(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
