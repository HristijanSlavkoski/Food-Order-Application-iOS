//
//  ShowNearbyCompaniesTableViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/17/23.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class ShowNearbyCompaniesTableViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    var firebaseAuth: Auth!
    var firebaseUser: FirebaseAuth.User!
    var firebaseDatabase: Database!
    var databaseReference: DatabaseReference!
    var companies = [Company]()
    var companyIds = [String]()
    
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
                let isApproved = companyDictionary?["approved"] as? Bool
                if isApproved == true {
                    let company = Company(name: name!, imageUrl: imageUrl!, category: category, location: location, workingAtWeekends: workingAtWeekends!, workingAtNight: workingAtNight!, offersDelivery: offersDelivery!, foodArray: foodArray, managerUUID: managerUUID!, isApproved: isApproved!)
                    self.companies.append(company)
                    self.companyIds.append(companyId!)
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for (index, company) in companies.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.title = company.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: company.location.latitude, longitude: company.location.longitude)
            mapView.addAnnotation(annotation)
        }
        let region = MKCoordinateRegion(center: mapView.annotations.first!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeOrderSegue" {
            let destinationVC = segue.destination as! MakeOrderCustomerViewController
            let companyToBeSent = sender as! CompanyToBeSent
            destinationVC.company = companyToBeSent.company
            destinationVC.companyId = companyToBeSent.companyId
        }
    }
}

extension ShowNearbyCompaniesTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationTitle = view.annotation?.title else { return }
        
        for (index, company) in companies.enumerated() where company.name == annotationTitle {
            let companyToBeSent = CompanyToBeSent(company: company, companyId: companyIds[index])
            performSegue(withIdentifier: "makeOrderSegue", sender: companyToBeSent)
        }
    }
}
