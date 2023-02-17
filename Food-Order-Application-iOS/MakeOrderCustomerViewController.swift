//
//  MakeOrderCustomerViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/16/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import UserNotifications

class MakeOrderCustomerViewController: UIViewController, CLLocationManagerDelegate {
    
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    var company: Company?
    var companyId: String?
    var foodOrderList = [FoodOrder]()
    var totalPrice = 0.0
    @IBOutlet weak var deliveryToHomeLabel: UILabel!
    @IBOutlet weak var deliveryToHomeSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var totalPriceLabel: UILabel!
    var userLocation = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseAuth = Auth.auth()
        firebaseUser = firebaseAuth.currentUser
        firebaseDatabase = Database.database()
        databaseReference = firebaseDatabase.reference()
        if !company!.offersDelivery {
            deliveryToHomeLabel.isHidden = true
            deliveryToHomeSwitch.isHidden = true
        }
        if let foodArray = company?.foodArray {
            for food in foodArray {
                foodOrderList.append(FoodOrder(name: food.name, priceForEach: food.price, count: 0, totalPrice: 0))
            }
        }
        totalPriceLabel.text = "$\(totalPrice)"
        let nib = UINib(nibName: "FoodOrderMenuTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "foodOrderMenuTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func submitOrderClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Make Order", message: "Are you sure you want to make this order?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let userUUID = self.firebaseUser.uid
            let comapnyUUID = self.companyId
            let companyName = self.company!.name
            let managerUUID = self.company!.managerUUID
            let deliveryToHome = self.deliveryToHomeSwitch.isOn
            let customLocation: CustomLocationClass
            if deliveryToHome {
                customLocation = CustomLocationClass(longitude: self.userLocation.longitude, latitude: self.userLocation.latitude)
            } else {
                customLocation = CustomLocationClass(longitude: 0, latitude: 0)
            }
            let foodOrderArrayList = self.foodOrderList
            let comment = self.commentTextField.text
            
            if self.totalPrice == 0.0 {
                let toastMessage = "Please select at least 1 food"
                let alertController = UIAlertController(title: "Oops", message: toastMessage, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    alertController.dismiss(animated: true, completion: nil)
                }
            } else {
                let order = Order(userUUID: userUUID, companyUUID: comapnyUUID!, companyName: companyName, managerUUID: managerUUID, deliveryToHome: deliveryToHome, location: customLocation, foodOrderArrayList: foodOrderArrayList, comment: comment!, totalPrice: self.totalPrice, orderTaken: false, timestampWhenOrderWillBeFinishedInMillis: 0)
                let encoder = JSONEncoder()
                
                if let data = try? encoder.encode(order) {
                    let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    self.databaseReference.child("order").childByAutoId().setValue(dictionary) { (error, ref) in
                        if error == nil {
                            let toastMessage = "Order added successfully"
                            let alertController = UIAlertController(title: "Success", message: toastMessage, preferredStyle: .alert)
                            self.present(alertController, animated: true, completion: nil)
                            let content = UNMutableNotificationContent()
                            content.title = "New order"
                            content.body = "You have new order"

                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                            let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)

                            UNUserNotificationCenter.current().add(request) { (error) in
                                if let error = error {
                                    print("Error: \(error)")
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                alertController.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "orderAddedSuccessful", sender: nil)
                            }
                        } else {
                            let toastMessage = error!.localizedDescription
                            let alertController = UIAlertController(title: "Error", message: toastMessage, preferredStyle: .alert)
                            self.present(alertController, animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                alertController.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let toastMessage = "Logout successful"
        let alertController = UIAlertController(title: "Success", message: toastMessage, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            alertController.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "logoutSuccess", sender: nil)
        }
    }
}

extension MakeOrderCustomerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension MakeOrderCustomerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodOrderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodOrderMenuTableViewCell", for: indexPath) as! FoodOrderMenuTableViewCell
        cell.foodName.text = foodOrderList[indexPath.row].name
        cell.priceOfEach.text = String(foodOrderList[indexPath.row].priceForEach)
        cell.count.text = String(foodOrderList[indexPath.row].count)
        cell.totalPrice.text = String(foodOrderList[indexPath.row].totalPrice)
        
        cell.minusButtonAction = { [weak self] cell in
            var count = self!.foodOrderList[indexPath.row].count
            if count > 0 {
                count -= 1
                self!.foodOrderList[indexPath.row].count = count
                self!.foodOrderList[indexPath.row].totalPrice = Double(count) * self!.foodOrderList[indexPath.row].priceForEach
                self!.totalPrice = self!.totalPrice - self!.foodOrderList[indexPath.row].priceForEach
                self!.totalPriceLabel.text = "$\(self!.totalPrice)"
                cell.count.text = String(count)
                cell.totalPrice.text = String(self!.foodOrderList[indexPath.row].totalPrice)
                self?.foodOrderList[indexPath.row] = self!.foodOrderList[indexPath.row]
                tableView.reloadData()
            }
        }
        
        cell.plusButtonAction = { [weak self] cell in
            var count = self!.foodOrderList[indexPath.row].count
            count += 1
            self!.foodOrderList[indexPath.row].count = count
            self!.foodOrderList[indexPath.row].totalPrice = Double(count) * self!.foodOrderList[indexPath.row].priceForEach
            self!.totalPrice = self!.totalPrice + self!.foodOrderList[indexPath.row].priceForEach
            self!.totalPriceLabel.text = "$\(self!.totalPrice)"
            cell.count.text = String(count)
            cell.totalPrice.text = String(self!.foodOrderList[indexPath.row].totalPrice)
            self?.foodOrderList[indexPath.row] = self!.foodOrderList[indexPath.row]
            tableView.reloadData()
        }
        return cell
    }
}
