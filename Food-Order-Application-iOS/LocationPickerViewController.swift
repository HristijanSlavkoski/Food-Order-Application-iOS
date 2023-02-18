//
//  LocationPickerViewController.swift
//  Food-Order-Application-iOS
//
//  Created by Hristijan Slavkoski on 2/15/23.
//

import UIKit
import MapKit

class LocationPickerViewController: UIViewController {

    
    @IBOutlet weak var mapkit: MKMapView!
    var selectedCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                mapkit.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    @objc func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
           let location = gestureRecognizer.location(in: mapkit)
           let coordinate = mapkit.convert(location, toCoordinateFrom: mapkit)
           
           selectedCoordinate = coordinate
           
           let annotation = MKPointAnnotation()
           annotation.coordinate = coordinate
           mapkit.removeAnnotations(mapkit.annotations)
           mapkit.addAnnotation(annotation)
       }

    @IBAction func confirmButtonClicked(_ sender: Any) {
        if mapkit.annotations.count==0 {
            let toastMessage = "Please select location"
            let alertController = UIAlertController(title: "Oops", message: toastMessage, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        else {
            self.performSegue(withIdentifier: "confirmLocationSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmLocationSegue" {
            let destinationVC = segue.destination as! CreateNewCompanyViewController
            destinationVC.longitude = selectedCoordinate!.longitude
            destinationVC.latitude = selectedCoordinate!.latitude
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
