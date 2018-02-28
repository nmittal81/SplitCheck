//
//  TotalTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

protocol TotalTableViewCellDelegate {
    func totalCheckEntered(value: Double)
    func nameOfEventEntered(value: String)
}

enum CellType {
    case Name
    case Total
}
class TotalTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var totalTextField: UITextField!
    
    var delegate: TotalTableViewCellDelegate?
    
    var textTimer: Timer?
    var cellType: CellType = .Name
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.totalTextField.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func textFieldDidEditingChanged(_ textField: UITextField) {
        
        // if a timer is already active, prevent it from firing
        if textTimer != nil {
            textTimer?.invalidate()
            textTimer = nil
        }
        // reschedule the search: in 1.0 second, call the searchForKeyword method on the new textfield content
        textTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(textEntered(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func textEntered(_ timer: Timer) {
        if cellType == .Total, let text = totalTextField.text?.replacingOccurrences(of: "$", with: ""), text != "", let doubleVal = Double(text) {
            delegate?.totalCheckEntered(value: doubleVal)
        } else if let text = totalTextField.text {
            delegate?.nameOfEventEntered(value: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
