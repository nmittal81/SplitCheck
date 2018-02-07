//
//  ViewController.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/7/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var numberOfPeople = 0

    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            let totalNumber = Int(numberOfPeopleTextField.text!)!
            vc.numberOfCells = totalNumber
            vc.drinksValue = [Double](repeating: 0, count: totalNumber)
            vc.peopleArray = [String](repeating: "", count: totalNumber)
            vc.totalArray = [Double](repeating: 0, count: totalNumber)
        }
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.numberOfPeople = Int(textField.text!)!
    }
}

