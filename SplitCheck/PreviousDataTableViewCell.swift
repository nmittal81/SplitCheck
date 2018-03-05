//
//  PreviousDataTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/13/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

class PreviousDataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setUpView(event: Events) {
        title.text = event.title
        date.text = event.date
        location.text = event.location
    }
}
