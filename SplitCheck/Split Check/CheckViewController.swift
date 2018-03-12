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
import GoogleMobileAds
 
 let memberSection = 3
  
class CheckViewController: UIViewController {

    var bannerView: GADBannerView!
    var totalCheck = 0.0
    var titleOfEvent = ""
    var locationOfEvent: OrgSearch?
    var memberArray = [MemberOfEvent]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var introView: UIView!
    var event: Events?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: kIntroViewShown) == nil {
            tableView.isHidden = true
        } else {
            introView.isHidden = true
            addBannerAd()
        }
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CheckViewController.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CheckViewController.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CheckViewController.pushGoogleVC(_:)),
                                               name: NSNotification.Name(rawValue: "LocationEdit"),
                                               object: nil)
        
        if let event = event {
            totalCheck = event.amount
            if let _ = event.members {
                tableView.reloadData()
            }
        }
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(CheckViewController.dismissKeyboardView))
        tableView.addGestureRecognizer(dismissKeyboardTap)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addBannerAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        #if DEBUG
        bannerView.adUnitID = adMobDebugAppBannerId
        #else
        bannerView.adUnitID = adMobAppBannerId
        #endif
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @IBAction func closeIntroView(_ sender: Any) {
        introView.isHidden = true
        tableView.isHidden = false
        UserDefaults.standard.set(true, forKey: kIntroViewShown)
        addBannerAd()
    }

    @objc func dismissKeyboardView() {
        view.endEditing(true)
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
        if introView.isHidden == false {
            return
        }
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
        if introView.isHidden == false {
            return
        }
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
    
    @objc func pushGoogleVC(_ notification: Notification) {
        performSegue(withIdentifier: "GooglePlacesViewController", sender: self)
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
        newEvent.location = locationOfEvent?.title
        newEvent.members = NSSet(array: memberArray)
        self.event = newEvent
        DataBaseController.saveContext()
    }

}

extension CheckViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case memberSection: return memberArray.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 2: return "Enter the amount of check"
        case 3: return "Enter the location"
        case 4: return "Please enter name, drinks tab and we will do the rest"
        case 5: return "Calculate"
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
        
        if (section == memberSection) {
            let view = PersonHeaderView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            view.delegate = self
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            var headerTitle = ""
            switch(section) {
            case 1: headerTitle = "Enter the location"
            case 2: headerTitle = "Enter the amount of check"
            case 4: headerTitle = "Please enter name, drinks tab and we will do the rest"
            case 5: headerTitle = "Calculate"
            default: headerTitle = "Name the occasion"
            }
            headerView.textLabel?.text = headerTitle
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell", for: indexPath) as! TotalTableViewCell
            cell.totalTextField.keyboardType = .default
            cell.totalTextField.placeholder = "NAME"
            cell.cellType = .Name
            if titleOfEvent != "" {
                cell.totalTextField.text = titleOfEvent
            } else if let event = event {
                cell.totalTextField.text = event.title
            } else {
                cell.totalTextField.text = ""
            }
            cell.delegate = self
            return cell
        } else if indexPath.section == 2 {
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
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
            cell.locationTextField.keyboardType = .default
            cell.locationTextField.placeholder = "LOCATION"
//            cell.delegate = self
            if let locationOfEvent = locationOfEvent {
                cell.locationTextField.text = locationOfEvent.title
            } else if let event = event {
                cell.locationTextField.text = event.location
            } else {
                cell.locationTextField.text = ""
            }
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
        if (indexPath.section == 3) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if ((indexPath.section == memberSection) && editingStyle == UITableViewCellEditingStyle.delete) {
            memberArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Coming here instead")
        if indexPath.section == 1 {
            performSegue(withIdentifier: "GooglePlacesViewController", sender: self)
        }
    }
}

extension CheckViewController: TotalTableViewCellDelegate {
    func totalCheckEntered(value: Double) {
        self.totalCheck = value
    }
    
    func nameOfEventEntered(value: String, cellType: CellType) {
        if cellType == .Name {
            self.titleOfEvent = value
        }
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
        self.event = nil
        self.memberArray.removeAll()
        self.memberArray = [MemberOfEvent]()
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
            member.drinks = 0.0
            member.food = 0.0
            member.total = 0.0
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
 
 extension CheckViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        addBannerViewToView(bannerView)
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
 }
