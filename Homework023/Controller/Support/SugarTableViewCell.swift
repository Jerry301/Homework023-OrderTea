//
//  SugarTableViewCell.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/28.
//

import UIKit

protocol SugarTableViewCellDelegate: AnyObject {
    func toggleSugarSegmentedCtrl(with index: Int)
}

class SugarTableViewCell: UITableViewCell {
    
    weak var delegate : SugarTableViewCellDelegate?
    
    @IBOutlet weak var sugarSegmentedControl: UISegmentedControl!
    
    private var Index: Int? {
        return sugarSegmentedControl.selectedSegmentIndex
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func toggleSugarSegmentedCtrl(_ sender: UISegmentedControl) {
        delegate?.toggleSugarSegmentedCtrl(with: Index!)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
