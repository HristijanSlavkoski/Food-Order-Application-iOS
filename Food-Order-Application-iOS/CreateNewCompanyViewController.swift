//
//  CreateNewCompanyViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/15/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AlamofireImage

class CreateNewCompanyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var categorySpinner: UIPickerView!
    @IBOutlet weak var workingAtWeekendsSwitch: UISwitch!
    @IBOutlet weak var workingAtNightSwitch: UISwitch!
    @IBOutlet weak var offersDeliverySwitch: UISwitch!
    @IBOutlet weak var addFoodItemButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var locationImage: UIImageView!
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    let categories = ["Fast Food", "Seafood", "Restaurant", "Dessert"]
    var foodArray: [Food] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseAuth = Auth.auth()
        firebaseUser = firebaseAuth.currentUser
        firebaseDatabase = Database.database()
        databaseReference = firebaseDatabase.reference()
        
        if !(longitude==0.0) {
            let url = "http://maps.google.com/maps/api/staticmap?center=\(latitude),\(longitude)&zoom=15&size=400x250&sensor=false&key=AIzaSyAwsgZwwxsXSOYpvzjU-NR86ffnKaQxK-4"
            print(url)
            locationImage.af_setImage(withURL: URL(string: url)!)
        }
        menuTableView.dataSource = self
        categorySpinner.delegate = self
        categorySpinner.dataSource = self
    }
    
    @IBAction func addFoodItemClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Add Food Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Food Name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Food Price"
            textField.keyboardType = .decimalPad
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] (_) in
            guard let name = alert.textFields?[0].text, let priceString = alert.textFields?[1].text, let price = Double(priceString) else {
                return
            }
            
            let food = Food(name: name, price: price)
            self?.foodArray.append(food)
            self?.menuTableView.reloadData()
        }
        
        alert.addAction(submitAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        let name = companyName.text
        let categoryIndex = categorySpinner.selectedRow(inComponent: 0)
        let category: CompanyCategory
        switch categoryIndex {
        case 0:
            category = .FAST_FOOD
        case 1:
            category = .SEAFOOD
        case 2:
            category = .RESTAURANT
        case 3:
            category = .DESSERT
        default:
            category = .FAST_FOOD
        }
        let workingAtWeekends = workingAtWeekendsSwitch.isOn
        let workingAtNight = workingAtNightSwitch.isOn
        let offersDelivery = offersDeliverySwitch.isOn
        
        if !(name?.isEmpty ?? true) && category != nil && latitude != 0.0 && longitude != 0.0 {
            let company = Company(name: name!, imageUrl: "", category: category, location: CustomLocationClass(longitude: longitude, latitude: latitude), workingAtWeekends: workingAtWeekends, workingAtNight: workingAtNight, offersDelivery: offersDelivery, foodArray:foodArray, managerUUID: firebaseAuth.currentUser!.uid, isApproved: false)
            let encoder = JSONEncoder()
            
            if let data = try? encoder.encode(company) {
                let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                
                
                databaseReference.child("company").childByAutoId().setValue(dictionary) { (error, ref) in
                    if error == nil {
                        let toastMessage = "Company added successfully"
                        let alertController = UIAlertController(title: "Success", message: toastMessage, preferredStyle: .alert)
                        self.present(alertController, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            alertController.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "companyAddedSuccesfully", sender: nil)
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
        else {
            let toastMessage = "Please fill all the fields"
            let alertController = UIAlertController(title: "Oops", message: toastMessage, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                alertController.dismiss(animated: true, completion: nil)
            }
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}

extension CreateNewCompanyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        cell.detailTextLabel?.text = "$\(foodArray[indexPath.row].price)"
        return cell
    }
}

