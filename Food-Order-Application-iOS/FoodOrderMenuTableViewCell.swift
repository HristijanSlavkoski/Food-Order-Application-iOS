//
//  FoodOrderMenuTableViewCell.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/16/23.
//

import UIKit

class FoodOrderMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var priceOfEach: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var totalPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        minusButton.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    var minusButtonAction: ((FoodOrderMenuTableViewCell) -> Void)?
    var plusButtonAction: ((FoodOrderMenuTableViewCell) -> Void)?
    
    @objc func didTapMinusButton() {
        minusButtonAction?(self)
    }
    
    @objc func didTapPlusButton() {
        plusButtonAction?(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
