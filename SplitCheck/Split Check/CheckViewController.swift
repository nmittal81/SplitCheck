//
//  CheckViewController.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

class CheckViewController: UIViewController {

    var numberOfCells = 0
    var totalCheck = 0.0
    var drinksValue = [Double]()
    var peopleArray = [String]()
    var totalArray = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        case 1: return "Name                    Drinks       Food           Total"
        case 2: return "Calculate"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
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
    }
}
