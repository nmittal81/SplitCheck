//
//  PersonTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

protocol PersonTableViewCellDelegate {
    func drinkCheckEntered(value: Double, tag: Int)
    func nameEntered(value: String, tag: Int)
    func totalCalculated(value: Double, tag: Int)
}

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var drinksTextField: UITextField!
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var totalLabelField: UILabel!

    var indexOfCell = 0
    
    var textTimer: Timer?
    var delegate: PersonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.drinksTextField.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTextField(_:)), name: NSNotification.Name(rawValue: "TotalCalculated"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func updateTextField(_ notification: Notification) {
        if let userInfo = notification.userInfo
        , let amount = userInfo["Amount"] as? Double {
            foodTextField.text = "$\(amount.rounded(toPlaces: 1))"
            var total = amount
            if let text = drinksTextField.text, let val =  Double(text) {
             total = amount + val
            }
            totalLabelField.text = "$\(total.rounded(toPlaces: 1))"
            delegate?.totalCalculated(value: total, tag: indexOfCell)
        }
    }
    
    @objc func textFieldDidEditingChanged(_ textField: UITextField) {
        
        // if a timer is already active, prevent it from firing
        if textTimer != nil {
            textTimer?.invalidate()
            textTimer = nil
        }
        
        if (textField == drinksTextField) {
            textTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(textEnteredForDrinks(_:)), userInfo: nil, repeats: false)
        } else if (textField == nameTextField) {
            textTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(textEnteredForName(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc func textEnteredForDrinks(_ timer: Timer) {
        if let text = drinksTextField.text?.replacingOccurrences(of: "$", with: ""), let val =  Double(text) {
            delegate?.drinkCheckEntered(value: val, tag: indexOfCell)
        }
    }
    
    @objc func textEnteredForName(_ timer: Timer) {
        if let text = nameTextField.text, text != "" {
            delegate?.nameEntered(value: nameTextField.text!, tag: indexOfCell)
        }
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
