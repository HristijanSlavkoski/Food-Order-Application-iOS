//
//  CustomerHomePageViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CustomerHomePageViewController: UIViewController {
    
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    var companies = [Company]()
    var companyIds = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseAuth = Auth.auth()
        firebaseUser = firebaseAuth.currentUser
        firebaseDatabase = Database.database()
        databaseReference = firebaseDatabase.reference()
        
        databaseReference.child("company").observeSingleEvent(of: .value, with: { (snapshot) in
            for dataSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let companyId = dataSnapshot.key as? String
                let companyDictionary = dataSnapshot.value as? NSDictionary
                let name = companyDictionary?["name"] as? String
                let imageUrl = companyDictionary?["imageUrl"] as? String
                let categoryRawValue = companyDictionary?["category"] as? String
                let category: CompanyCategory
                switch categoryRawValue {
                case "FAST_FOOD":
                    category = .FAST_FOOD
                case "SEAFOOD":
                    category = .SEAFOOD
                case "RESTAURANT":
                    category = .RESTAURANT
                case "DESSERT":
                    category = .DESSERT
                default:
                    category = .FAST_FOOD
                }
                let locationAsDictionary = companyDictionary?["location"] as? NSDictionary
                let longitude = locationAsDictionary?["longitude"] as? Double
                let latitude = locationAsDictionary?["latitude"] as? Double
                let location = CustomLocationClass(longitude: longitude!, latitude: latitude!)
                let workingAtWeekends = companyDictionary?["workingAtWeekends"] as? Bool
                let workingAtNight = companyDictionary?["workingAtNight"] as? Bool
                let offersDelivery = companyDictionary?["offersDelivery"] as? Bool
                let foodArrayAsArrayOfDictionaries = companyDictionary?["foodArray"] as? [NSDictionary]
                var foodArray: [Food] = []
                for foodDictionary in foodArrayAsArrayOfDictionaries! {
                    let foodName = foodDictionary["name"] as? String
                    let foodPrice = foodDictionary["price"] as? Double
                    let food = Food(name: foodName!, price: foodPrice!)
                    foodArray.append(food)
                }
                let managerUUID = companyDictionary?["managerUUID"] as? String
                let approved = companyDictionary?["approved"] as? Bool
                if approved == true {
                    let company = Company(name: name!, imageUrl: imageUrl!, category: category, location: location, workingAtWeekends: workingAtWeekends!, workingAtNight: workingAtNight!, offersDelivery: offersDelivery!, foodArray: foodArray, managerUUID: managerUUID!, approved: approved!)
                    self.companies.append(company)
                    self.companyIds.append(companyId!)
                    self.tableView.reloadData()
                }
            }
        })
        let nib = UINib(nibName: "CompanyCustomerTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "companyCustomerTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeOrderSegue" {
            let destinationVC = segue.destination as! MakeOrderCustomerViewController
            let companyToBeSent = sender as! CompanyToBeSent
            destinationVC.company = companyToBeSent.company
            destinationVC.companyId = companyToBeSent.companyId
        }
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

extension CustomerHomePageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension CustomerHomePageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyCustomerTableViewCell", for: indexPath) as! CompanyCustomerTableViewCell
        let company = companies[indexPath.row]
        cell.title.text = company.name
        cell.category.text = company.category.rawValue
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let dayOfWeek = calendar.component(.weekday, from: Date())

        if !company.workingAtNight {
            if hour >= 7 {
                cell.workingNow.text = "Closes at 00:00"
                cell.workingNow.backgroundColor = .green
            } else {
                cell.workingNow.text = "Opens at 08:00"
                cell.workingNow.backgroundColor = .red
            }
        } else {
            cell.workingNow.text = "Working 24/7"
            cell.workingNow.backgroundColor = .green
        }

        if !company.workingAtWeekends {
            if dayOfWeek == 7 || dayOfWeek == 1 {
                cell.workingNow.text = "Closed during weekends"
                cell.workingNow.backgroundColor = .red
            }
        }

        if company.offersDelivery {
            cell.offersDelivery.text = "Delivery available"
            cell.offersDelivery.backgroundColor = .green
        } else {
            cell.offersDelivery.text = "Delivery is not available"
            cell.offersDelivery.backgroundColor = .red
        }
        
        cell.buttonAction = { [weak self] cell in
            let alert = UIAlertController(title: "Confirm", message: "Order food from this company?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                let companyToBeSent = CompanyToBeSent(company: (self?.companies[indexPath.row])!, companyId: self!.companyIds[indexPath.row])
                self!.performSegue(withIdentifier: "makeOrderSegue", sender: companyToBeSent)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true, completion: nil)
        }
        cell.button.setTitle("Order food", for: .normal)
        cell.button.backgroundColor = UIColor.blue
        return cell
    }
}
