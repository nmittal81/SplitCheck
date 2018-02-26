 //
//  CheckViewController.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class CheckViewController: UIViewController {

    var totalCheck = 0.0
    var titleOfEvent = ""
    var memberArray = [MemberOfEvent]()
    @IBOutlet weak var tableView: UITableView!
    var event: Events?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CheckViewController.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CheckViewController.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        if let event = event {
            totalCheck = event.amount
            if let members = event.members {
                tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        var textToShare = ""
        for member in memberArray {
            textToShare += "\(member.fname)  \(member.total)\n"
        }
        
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func showPreviousSplits() {
        performSegue(withIdentifier: "MainViewController", sender: self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    func saveDetailsToDB() {
        var newEvent: Events
        if let savedEvent = event {
            newEvent = savedEvent
            newEvent.removeFromMembers(newEvent.members!)
        } else {
            newEvent = NSEntityDescription.insertNewObject(forEntityName: "Events", into: DataBaseController.getContext()) as! Events
        }
        newEvent.amount = self.totalCheck
        newEvent.number = Int16(memberArray.count)
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "MMM d, yyyy"
        
        let myDateString = formatter.string(from: Date())
        
        newEvent.date = myDateString
        newEvent.title = titleOfEvent
        newEvent.members = NSSet(array: memberArray)
        DataBaseController.saveContext()
    }

}

extension CheckViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 2: return memberArray.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 1: return "Enter total amount of your check"
        case 2: return "Please enter name, drinks tab and we will do the rest"
        case 3: return "Calculate"
        default: return "Name the occasion"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 2) {
            let view = PersonHeaderView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            view.delegate = self
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
            cell.totalTextField.keyboardType = .default
            cell.totalTextField.placeholder = "NAME"
            cell.cellType = .Name
            cell.totalTextField.text = event?.title
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
            if totalCheck != 0.0 {
                cell.totalTextField.text = "$\(totalCheck)"
            } else {
                cell.totalTextField.text = ""
            }
            cell.delegate = self
            cell.totalTextField.keyboardType = .decimalPad
            cell.cellType = .Total
            return cell
        } else if indexPath.section == tableView.numberOfSections - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitTableViewCell", for: indexPath) as! SubmitTableViewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
            cell.delegate = self
            cell.member = memberArray[indexPath.row]
            cell.updateView()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 2) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if ((indexPath.section == 2) && editingStyle == UITableViewCellEditingStyle.delete) {
            memberArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension CheckViewController: TotalTableViewCellDelegate {
    func totalCheckEntered(value: Double) {
        self.totalCheck = value
    }
    
    func nameOfEventEntered(value: String) {
        titleOfEvent = value
    }
}

extension CheckViewController: PersonTableViewCellDelegate {
    func drinkCheckEntered(value: Double, member: MemberOfEvent) {
        member.drinks = value
    }
    
    func nameEntered(value: String, member: MemberOfEvent) {
        member.fname = value
    }
}

extension CheckViewController: SubmitTableViewCellDelegate {
    func calculateFoodSplit() {
        dismissKeyboard()
        if totalCheck == 0 {
            return
        }
        var sum = 0.0
        for member in memberArray {
            sum += member.drinks
        }
        let foodAmount = (totalCheck - sum)/Double(memberArray.count)
        let userInfo = ["Amount": foodAmount]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TotalCalculated"), object: nil, userInfo: userInfo)
        self.saveDetailsToDB()
    }
    
    func clear() {
        totalCheck = 0.0
        titleOfEvent = ""
        tableView.reloadData()
    }
}

extension CheckViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts {
            let entity = NSEntityDescription.entity(forEntityName: "MemberOfEvent", in: DataBaseController.getContext())
            let member = MemberOfEvent(entity: entity!, insertInto: DataBaseController.getContext())
            member.fname = contact.givenName
            memberArray.append(member)
            tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CheckViewController: PersonHeaderViewDelegate {
    func addPerson() {
        let entity = NSEntityDescription.entity(forEntityName: "MemberOfEvent", in: DataBaseController.getContext())
        let member = MemberOfEvent(entity: entity!, insertInto: DataBaseController.getContext())
        memberArray.append(member)
        tableView.reloadData()
    }
    
    func importContacts() {
        
        ContactsHandler.sharedInstance.requestForAccess{(accessGranted) -> Void in
            if accessGranted {
                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = self;
                contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
                
                self.present(contactPicker, animated: true, completion: nil)
            }
        }
    }
}
 
 extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
 }
