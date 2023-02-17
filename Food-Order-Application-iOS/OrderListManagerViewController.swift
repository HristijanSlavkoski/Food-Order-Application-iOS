//
//  OrderListManagerViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/17/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OrderListManagerViewController: UIViewController {
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    var orders: [Order] = []
    var orderIds: [String] = []
    @IBOutlet weak var tableView: UITableView!
    
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
                if order.managerUUID == self.firebaseUser.uid {
                    self.orders.append(order)
                    self.orderIds.append(dataSnapshot.key)
                    self.tableView.reloadData()
                }
            }
        })
        let nib = UINib(nibName: "OrderItemManagerTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "orderItemManagerTableViewCell")
        tableView.delegate = self
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

extension OrderListManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension OrderListManagerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderItemManagerTableViewCell", for: indexPath) as! OrderItemManagerTableViewCell
        
        let order = orders[indexPath.row]
        cell.name.text = order.companyName
        if order.deliveryToHome {
            cell.delivery.text = "Delivery"
        }
        else {
            cell.delivery.text = "Takeout"
        }
        cell.price.text = "$\(order.totalPrice)"
        if order.orderTaken {
            cell.button.setTitle("Order taken", for: .normal)
            cell.button.backgroundColor = UIColor.gray
            cell.button.isUserInteractionEnabled = false
        }
        else {
            cell.button.setTitle("Take order", for: .normal)
            cell.button.backgroundColor = UIColor.blue
            cell.button.isUserInteractionEnabled = true
        }
        cell.buttonAction = { [weak self] cell in
            let alert = UIAlertController(title: "Confirm", message: "Enter number of minutes for order to be ready", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Number of minutes"
                textField.keyboardType = .numberPad
            }
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                let minutesTextField = alert.textFields![0] as UITextField
                if let minutes = Int64(minutesTextField.text!) {
                    let id = self!.orderIds[indexPath.row]
                    self?.databaseReference.child("order").child(id).updateChildValues(["orderTaken": true])
                    self?.databaseReference.child("order").child(id).updateChildValues(["timestampWhenOrderWillBeFinishedInMillis": Int64(Date().timeIntervalSince1970 * 1000) + minutes * 60 * 1000])
                    self?.orders[indexPath.row].orderTaken = true
                    self?.tableView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true, completion: nil)
        }
        return cell
    }
}
