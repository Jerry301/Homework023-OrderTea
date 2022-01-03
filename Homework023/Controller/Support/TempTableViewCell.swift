//
//  TempTableViewCell.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/28.
//

import UIKit

protocol TempTableViewCellDelegate: AnyObject {
    func toggleTempSegmentedCtrl(with index: Int)
}

class TempTableViewCell: UITableViewCell {
    
    weak var delegate: TempTableViewCellDelegate?
    
    @IBOutlet weak var tempSegmentedControl: UISegmentedControl!
    

    private var index: Int? {
        return tempSegmentedControl.selectedSegmentIndex
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func toggleTempSegmentCtrl(_ sender: UISegmentedControl) {
        
        delegate?.toggleTempSegmentedCtrl(with: index!)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
