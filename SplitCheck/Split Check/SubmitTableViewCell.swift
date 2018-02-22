//
//  SubmitTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

protocol SubmitTableViewCellDelegate {
    func calculateFoodSplit()
    func clear()
}

class SubmitTableViewCell: UITableViewCell {

    @IBOutlet weak var submitButton: UIButton!
    var delegate: SubmitTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func submitClicked(_ sender: UIButton) {
        delegate?.calculateFoodSplit()
    }
    
    @IBAction func clearClicked(_ sender: UIButton) {
        delegate?.clear()
    }
}
