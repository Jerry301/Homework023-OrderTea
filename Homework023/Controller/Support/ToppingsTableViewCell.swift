//
//  ToppingsTableViewCell.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/28.
//

import UIKit

class ToppingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addToppingBtn: UIButton!
    @IBOutlet weak var toppingNameLabel: UILabel!
    @IBOutlet weak var toppingPriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
