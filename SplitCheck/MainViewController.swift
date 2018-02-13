//
//  ViewController.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    var numberOfPeople = 0

    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var dataPreviouslyStored = [Events]()
    var selectedEvent: Events?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedEvent = nil
        numberOfPeopleTextField.text = "0"
        let fetchRequest:NSFetchRequest<Events> = Events.fetchRequest()
        do {
            dataPreviouslyStored = try DataBaseController.getContext().fetch(fetchRequest)
            if dataPreviouslyStored.count == 0 {
                tableView.isHidden = true
            } else {
                tableView.reloadData()
            }
        } catch {
            print("Error \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneClicked(_ sender: Any) {
        performSegue(withIdentifier: "CheckViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CheckViewController", let navController = segue.destination as? UINavigationController  {
            let vc = navController.topViewController as! CheckViewController
            if let selectedEvent = selectedEvent {
                vc.event = selectedEvent
                vc.numberOfCells = Int(selectedEvent.number)
            } else {
                let totalNumber = Int(numberOfPeopleTextField.text!)!
                vc.numberOfCells = totalNumber
                vc.drinksValue = [Double](repeating: 0, count: totalNumber)
                vc.peopleArray = [String](repeating: "", count: totalNumber)
                vc.totalArray = [Double](repeating: 0, count: totalNumber)
            }
        }
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.numberOfPeople = Int(textField.text!)!
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataPreviouslyStored.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Previously Stored Events"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousDataCell", for: indexPath) as! PreviousDataTableViewCell
        let event = dataPreviouslyStored[indexPath.row]
        cell.setUpView(event: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = dataPreviouslyStored[indexPath.row]
        performSegue(withIdentifier: "CheckViewController", sender: self)
    }
}

