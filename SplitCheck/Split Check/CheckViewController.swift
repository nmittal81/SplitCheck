//
//  CheckViewController.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import CoreData

class CheckViewController: UIViewController {

    var numberOfCells = 0
    var totalCheck = 0.0
    var drinksValue = [Double]()
    var peopleArray = [String]()
    var totalArray = [Double]()
    var managedObjectContext: NSManagedObjectContext? = nil
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
                for member in members {
                    let member = member as! MemberOfEvent
                    peopleArray.append(member.fname!)
                    drinksValue.append(member.drinks)
                    totalArray.append(member.total)
                }
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
            textToShare += "\(peopleArray[i])  \(totalArray[i])\n"
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
        let event: Events = NSEntityDescription.insertNewObject(forEntityName: "Events", into: DataBaseController.getContext()) as! Events
        event.amount = self.totalCheck
        event.number = Int16(numberOfCells)
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "MMM d, yyyy @ HH:MMa"
        
        let myDateString = formatter.string(from: Date())
        
        event.date = myDateString
        event.title = title
        
        for i in 0...numberOfCells {
            let member: MemberOfEvent = NSEntityDescription.insertNewObject(forEntityName: "MemberOfEvent", into: DataBaseController.getContext()) as! MemberOfEvent
            member.fname = peopleArray[i]
            member.drinks = drinksValue[i]
            member.total = totalArray[i]
            member.food = totalArray[i] - drinksValue[i]
            event.addToMembers(member)
        }
        DataBaseController.saveContext()
    }

}

extension CheckViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
            if totalCheck != 0.0 {
                cell.totalTextField.text = "\(totalCheck)"
            }
            cell.delegate = self
            return cell
        } else if indexPath.section == tableView.numberOfSections - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitTableViewCell", for: indexPath) as! SubmitTableViewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
            cell.indexOfCell = indexPath.row
            cell.delegate = self
            if let _ = event {
                cell.nameTextField.text = peopleArray[indexPath.row]
                cell.drinksTextField.text = "\(drinksValue[indexPath.row])"
                cell.totalLabelField.text = "\(totalArray[indexPath.row])"
                cell.foodTextField.text = "\(totalArray[indexPath.row] - drinksValue[indexPath.row])"
            }
            return cell
        }
    }
}

extension CheckViewController: TotalTableViewCellDelegate {
    func totalCheckEntered(value: Double) {
        self.totalCheck = value
    }
}

extension CheckViewController: PersonTableViewCellDelegate {
    func drinkCheckEntered(value: Double, tag: Int) {
        drinksValue.insert(value, at: tag)
    }
    
    func nameEntered(value: String, tag: Int) {
        peopleArray.insert(value, at: tag)
    }
    
    func totalCalculated(value: Double, tag: Int) {
        totalArray.insert(value, at: tag)
    }
}

extension CheckViewController: SubmitTableViewCellDelegate {
    func calculateFoodSplit() {
        let sum = drinksValue.reduce(0, +) as Double
        let foodAmount = (self.totalCheck - sum)/Double(numberOfCells)
        let userInfo = ["Amount": foodAmount]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TotalCalculated"), object: nil, userInfo: userInfo)
        let alertController = UIAlertController.init(title: "Save", message: "Do you want to save this split?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
            _ in
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
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
