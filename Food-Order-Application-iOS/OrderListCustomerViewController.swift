//
//  OrderListCustomerViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/17/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OrderListCustomerViewController: UIViewController {
    
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var orders: [Order] = []
    var orderIds: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseAuth = Auth.auth()
        firebaseUser = firebaseAuth.currentUser
        firebaseDatabase = Database.database()
        databaseReference = firebaseDatabase.reference()
        // Do any additional setup after loading the view.
        
        databaseReference.child("order").observeSingleEvent(of: .value, with: { (snapshot) in
            for dataSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let orderDictionary = dataSnapshot.value as? NSDictionary
                let userUUID = orderDictionary?["userUUID"] as? String
                let companyUUID = orderDictionary?["companyUUID"] as? String
                let companyName = orderDictionary?["companyName"] as? String
                let managerUUID = orderDictionary?["managerUUID"] as? String
                let deliveryToHome = orderDictionary?["deliveryToHome"] as? Bool
                let locationAsDictionary = orderDictionary?["location"] as? NSDictionary
                let longitude = locationAsDictionary?["longitude"] as? Double
                let latitude = locationAsDictionary?["latitude"] as? Double
                let location = CustomLocationClass(longitude: longitude!, latitude: latitude!)
                let foodOrderArrayListAsArrayOfDictionaries = orderDictionary?["foodOrderArrayList"] as? [NSDictionary]
                var foodOrderArrayList: [FoodOrder] = []
                for foodOrderDictionary in foodOrderArrayListAsArrayOfDictionaries! {
                    let foodName = foodOrderDictionary["name"] as? String
                    let foodPrice = foodOrderDictionary["priceForEach"] as? Double
                    let quantity = foodOrderDictionary["count"] as? Int
                    let totalPrice = foodOrderDictionary["totalPrice"] as? Double
                    let foodOrder = FoodOrder(name: foodName!, priceForEach: foodPrice!, count: quantity!, totalPrice: totalPrice!)
                    foodOrderArrayList.append(foodOrder)
                }
                let comment = orderDictionary?["comment"] as? String
                let totalPrice = orderDictionary?["totalPrice"] as? Double
                let orderTaken = orderDictionary?["orderTaken"] as? Bool
                let timestampWhenOrderWillBeFinishedInMillis = orderDictionary?["timestampWhenOrderWillBeFinishedInMillis"] as? Int64
                
                let order = Order(userUUID: userUUID!, companyUUID: companyUUID!, companyName: companyName!, managerUUID: managerUUID!, deliveryToHome: deliveryToHome!, location: location, foodOrderArrayList: foodOrderArrayList, comment: comment!, totalPrice: totalPrice!, orderTaken: orderTaken!, timestampWhenOrderWillBeFinishedInMillis: timestampWhenOrderWillBeFinishedInMillis!)
                self.orders.append(order)
                self.orderIds.append(dataSnapshot.key)
                self.tableView.reloadData()
            }
        })
        
        tableView.dataSource = self
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

extension OrderListCustomerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCustomerCell", for: indexPath)
        //        cell.textLabel?.text = orders[indexPath.row].companyName
        //        if !orders[indexPath.row].orderTaken {
        //            cell.detailTextLabel?.text = "Order is not taken yet"
        //        }
        //        else{
        //            let millis = orders[indexPath.row].timestampWhenOrderWillBeFinishedInMillis
        //            let orderDate = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        //            let currentTime = Date()
        //
        //            if currentTime < orderDate {
        //                let timeDifference = orderDate.timeIntervalSince(currentTime)
        //                let minutes = Int(timeDifference / 60)
        //                cell.detailTextLabel?.text = "Order is taken and it will be ready in \(minutes) minutes"
        //            } else {
        //                cell.detailTextLabel?.text = "Order is ready!"
        //            }
        //        }
        //        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCustomerCell", for: indexPath)
        cell.textLabel?.text = orders[indexPath.row].companyName
        
        let button = UIButton(type: .system)
        button.setTitle("Order is ready", for: .normal)
        button.addTarget(self, action: #selector(orderReadyButtonTapped), for: .touchUpInside)
        
        if !orders[indexPath.row].orderTaken {
            cell.detailTextLabel?.text = "Order is not taken yet"
            button.isHidden = true
        }
        else{
            let millis = orders[indexPath.row].timestampWhenOrderWillBeFinishedInMillis
            let orderDate = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
            let currentTime = Date()
            
            if currentTime < orderDate {
                let timeDifference = orderDate.timeIntervalSince(currentTime)
                let minutes = Int(timeDifference / 60)
                cell.detailTextLabel?.text = "Order is taken and it will be ready in \(minutes) minutes"
                button.isHidden = true
            } else {
                cell.detailTextLabel?.text = ""
                cell.contentView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16).isActive = true
            }
        }
        
        return cell
    }
    
    
    @objc func orderReadyButtonTapped(sender: UIButton) {
        if let cell = sender.superview?.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to receive this order?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                let id = self.orderIds[indexPath.row]
                self.databaseReference.child("order").child(id).removeValue()
                self.orders.remove(at: indexPath.row)
                self.orderIds.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)        }
    }
}

