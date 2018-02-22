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
    @IBOutlet weak var tableView: UITableView!
    
    var dataPreviouslyStored = [Events]()
    var selectedEvent: Events?
    @IBOutlet weak var noEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedEvent = nil
        let fetchRequest:NSFetchRequest<Events> = Events.fetchRequest()
        do {
            dataPreviouslyStored = try DataBaseController.getContext().fetch(fetchRequest)
            if dataPreviouslyStored.count == 0 {
                tableView.isHidden = true
            } else {
                noEventsLabel.isHidden = true
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
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CheckViewController", let vc = segue.destination as? CheckViewController  {
            if let selectedEvent = selectedEvent {
                vc.event = selectedEvent
                vc.memberArray = Array(selectedEvent.members!) as! [MemberOfEvent]
            }
        }
    }
    
    func removeEventFromDB(event: Events) {
        DataBaseController.getContext().delete(event)
        DataBaseController.saveContext()
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataPreviouslyStored.count
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let event = dataPreviouslyStored[indexPath.row]
            removeEventFromDB(event: event)
            dataPreviouslyStored.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

