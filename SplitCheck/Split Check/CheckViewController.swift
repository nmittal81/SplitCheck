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

    var numberOfCells = 0
    var totalCheck = 0.0
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
                self.numberOfCells = members.count
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
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareClicked(_ sender: UIBarButtonItem) {
        var textToShare = ""
        for i in 0...(numberOfCells - 1) {
            let member = memberArray[i]
            textToShare += "\(member.fname)  \(member.total)\n"
        }
        
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
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
    
    func saveDetailsToDB(title: String) {
        var newEvent: Events
        if let savedEvent = event {
            newEvent = savedEvent
            newEvent.removeFromMembers(newEvent.members!)
        } else {
            newEvent = NSEntityDescription.insertNewObject(forEntityName: "Events", into: DataBaseController.getContext()) as! Events
        }
        newEvent.amount = self.totalCheck
        newEvent.number = Int16(numberOfCells)
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "MMM d, yyyy"
        
        let myDateString = formatter.string(from: Date())
        
        newEvent.date = myDateString
        newEvent.title = title
        newEvent.members = NSSet(array: memberArray)
        DataBaseController.saveContext()
    }

}

extension CheckViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        case 1: return numberOfCells
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0: return "Enter total amount of your check"
        case 1: return "Please enter name, drinks tab and we will do the rest"
        case 2: return "Calculate"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 1) {
            let view = PersonHeaderView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            view.delegate = self
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
            if totalCheck != 0.0 {
                cell.totalTextField.text = "$\(totalCheck)"
            }
            cell.delegate = self
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
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            //TODO
            numberOfCells -= 1
            memberArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension CheckViewController: TotalTableViewCellDelegate {
    func totalCheckEntered(value: Double) {
        self.totalCheck = value
    }
}

extension CheckViewController: PersonTableViewCellDelegate {
    func drinkCheckEntered(value: Double, member: MemberOfEvent) {
        member.drinks = value
    }
    
    func nameEntered(value: String, member: MemberOfEvent) {
        member.fname = value
    }
    
    func totalCalculated(value: Double,  member: MemberOfEvent) {
        member.total = value
    }
}

extension CheckViewController: SubmitTableViewCellDelegate {
    func calculateFoodSplit() {
        if totalCheck == 0 {
            return
        }
        var sum = 0.0
        for i in 0...numberOfCells - 1 {
            let member = memberArray[i]
            sum += member.drinks
        }
        let foodAmount = (totalCheck - sum)/Double(numberOfCells)
        let userInfo = ["Amount": foodAmount]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TotalCalculated"), object: nil, userInfo: userInfo)
        let alertController = UIAlertController.init(title: "Save", message: "Do you want to save this split?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
            _ in
            if let event = self.event {
                self.saveDetailsToDB(title: event.title!)
            } else {
                let nameAlert = UIAlertController.init(title: "Name", message: "Give a title to celebration.", preferredStyle: .alert)
                nameAlert.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = "Event Name"
                    textField.textAlignment = .center
                })
                let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
                    _ in
                    let nameField = nameAlert.textFields![0] as UITextField
                    if let text = nameField.text, text != "" {
                        self.saveDetailsToDB(title: text)
                    }
                })
                nameAlert.addAction(okAction)
                
                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                nameAlert.addAction(cancelAction)
                self.present(nameAlert, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CheckViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var i = 0
        for member in memberArray {
            if i < contacts.count {
                member.fname = contacts[i].givenName
            }
            i += 1
        }
        tableView.reloadData()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CheckViewController: PersonHeaderViewDelegate {
    func addPerson() {
        numberOfCells += 1
        let entity = NSEntityDescription.entity(forEntityName: "MemberOfEvent", in: DataBaseController.getContext())
        let member = MemberOfEvent(entity: entity!, insertInto: DataBaseController.getContext())
        memberArray.append(member)
        tableView.reloadData()
    }
    
    func importContacts() {
        
        ContactsHandler.sharedInstance.requestForAccess{(accessGranted) -> Void in
            if accessGranted {
                //                let store = CNContactStore()
                
                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = self;
                contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
                
                self.present(contactPicker, animated: true, completion: nil)
                
                //                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
                //                let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                //                var cnContacts = [CNContact]()
                //
                //                do {
                //                    try store.enumerateContacts(with: request){
                //                        (contact, cursor) -> Void in
                //                        cnContacts.append(contact)
                //                    }
                //                } catch let error {
                //                    NSLog("Fetch contact error: \(error)")
                //                }
                //
                //                for contact in cnContacts {
                //                    let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                //                    print(fullName)
                //                }
            }
        }
    }
}
