//
//  GooglePlacesViewController.swift
//  Tadaah
//
//  Created by Neha Mittal on 9/11/17.
//  Copyright © 2017 Tadaah. All rights reserved.
//

import UIKit
import GooglePlaces

struct OrgSearch {
    var placeId = ""
    var title = ""
    var address = ""
    var keyForSelectedAddress = ""
    var location: CLLocation?
    
    init(placeId: String, title: String) {
        self.placeId = placeId
        self.title = title
    }
}

class GooglePlacesViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var textTimer: Timer?
    var resultsArray = [AnyObject]()
    
    var urlRequest: URLRequest?
    let config = URLSessionConfiguration.default
    var session: URLSession?
    var orgSearchResult: OrgSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicatorView.isHidden = true
        searchTextField.becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        session = URLSession(configuration: config)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        tableView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inviteClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InviteClicked"), object: nil, userInfo: nil)
    }
    
    @IBAction func clickHereClickedForManualOrgSearch(_ sender: Any) {
        performSegue(withIdentifier: "Business", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CheckViewFromGoogle", let vc = segue.destination as? CheckViewController {
            vc.locationOfEvent = orgSearchResult
        }
    }
}

extension GooglePlacesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let textTimer = textTimer {
            textTimer.invalidate()
            tableView.isHidden = true
            resultsArray.removeAll()
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
        }

        textTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {
            timer in
            
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
            var searchQuery = "\(googlePlacesAPI)input=\(textField.text!)&types=establishment"
//            if UserDefaults.standard.bool(forKey: "isLocationnabled") == true {
//                let lat = DataService.ds.latitudeMe
//                let long = DataService.ds.longitudeMe
//                searchQuery.append("&location=\(lat),\(long)")
//            }
            searchQuery.append("&key=\(googlePlaceAPIKey)")
            searchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            guard let url = URL(string: searchQuery) else {
                print("Error: cannot create URL")
                return
            }
            let urlRequest = URLRequest(url: url)
            let task = self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error)  in
                guard error == nil else {
                    print("error calling GET on /todos/1")
                    return
                }
                // make sure we got data
                guard let responseData = data else {
                    return
                }
                do {
                    guard let result = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    self.resultsArray = result["predictions"] as! [AnyObject]
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.isHidden = true
                        if self.resultsArray.count > 0 {
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                        }
                    }
                    // ...
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
            })
            task?.resume()

        }
        return true
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GooglePlacesViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
}

extension GooglePlacesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleSearchTableViewCell", for: indexPath)
        if let result = resultsArray[indexPath.row] as? [String: Any] {
            if let text = result["description"] as? String {
                cell.textLabel!.text = text
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = resultsArray[indexPath.row] as! [String: Any]
        let formattedText = result["structured_formatting"]! as! [String: Any]
        let selectedOrganization = formattedText["main_text"]! as! String
        let placeId = result["place_id"]! as! String
        
        orgSearchResult = OrgSearch.init(placeId: placeId, title: selectedOrganization)
        
        performSegue(withIdentifier: "CheckViewFromGoogle", sender: self)
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
