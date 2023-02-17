//
//  OrderItemManagerTableViewCell.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/17/23.
//

import UIKit

class OrderItemManagerTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var delivery: UILabel!
    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    var buttonAction: ((OrderItemManagerTableViewCell) -> Void)?
    
    @objc func didTapButton() {
        buttonAction?(self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
