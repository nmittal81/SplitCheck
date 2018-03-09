 //
//  LocationTableViewCell.swift
//  SplitCheck
//
//  Created by Neha Mittal on 3/8/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import GooglePlaces
 
class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var subTableView: UITableView!
    var resultsArray = [AnyObject]()
    let config = URLSessionConfiguration.default
    var session: URLSession?
    var textTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subTableView.isHidden = true
        activityIndicatorView.isHidden = true
        session = URLSession(configuration: config)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

 extension LocationTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let textTimer = textTimer {
            textTimer.invalidate()
            subTableView.isHidden = true
            resultsArray.removeAll()
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
        }
        
        textTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {
            timer in
            
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
            var searchQuery = "\(googlePlacesAPI)input=\(textField.text!)&types=establishment"
            searchQuery.append("&key=\(googlePlaceAPIKey)")
            searchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            guard let url = URL(string: searchQuery) else {
                print("Error: cannot create URL")
                return
            }
            let urlRequest = URLRequest(url: url)
            let task = self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error)  in
                guard error == nil else {
                    print("error")
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
                            self.subTableView.isHidden = false
                            self.subTableView.reloadData()
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
 }
 
 extension LocationTableViewCell: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
 }
 
 extension LocationTableViewCell: UITableViewDataSource {
    
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
        
        //        let orgSearchResult = OrgSearch.init(placeId: placeId, title: selectedOrganization)
    }
 }
