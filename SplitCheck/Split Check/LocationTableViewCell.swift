 //
//  LocationTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 3/8/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import GooglePlaces
 
class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

 extension LocationTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationEdit"), object: nil, userInfo: nil)
//        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: ""), object: self)
    }
 }
 
 
