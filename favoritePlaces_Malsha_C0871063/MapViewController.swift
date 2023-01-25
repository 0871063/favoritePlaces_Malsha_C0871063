//
//  MapViewController.swift
//  favoritePlaces_Malsha_C0871063
//
//  Created by Malsha Lambton on 2023-01-24.
//

import UIKit
import MapKit

//MARK: - Detegate methods
protocol MapViewDelegate {
    func setFavoriteLocation(place:PlaceObject)
    func deleteLocation(location: Location)
}

protocol HandleMapSearch: AnyObject {
    func setSearchLocation(coordinate : CLLocationCoordinate2D)
}

class MapViewController: UIViewController,CLLocationManagerDelegate,HandleMapSearch {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addBtn: UIButton!
    
    var locationMnager = CLLocationManager()
    var destination : CLLocationCoordinate2D?
    var address : String = ""
    var placeTitle : String = ""
    var resultSearchController: UISearchController?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: MapViewDelegate?
    
    var selectedLocation: Location? {
        didSet {
            editMode = true
        }
    }
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        
        addDoubleTap()
        //Search places controller load
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleLocationSearchDelegate = self
        
        if editMode{
            getLocationAddressAndAddPin(latitude: selectedLocation?.latitude ?? 0.0, longitude: selectedLocation?.longitude ?? 0.0)
            addBtn.setTitle("Update Location", for: .normal)
        }else{
            addBtn.setTitle("Add Location", for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Double Tap
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        getLocationAddressAndAddPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
        destination = coordinate
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String) {
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location
        annotation.subtitle = address
        
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        removePin()
        if !editMode{
            let userLocation = locations[0]
            
            destination = userLocation.coordinate
            let latitude = userLocation.coordinate.latitude
            let longitude = userLocation.coordinate.longitude
            getLocationAddressAndAddPin(latitude: latitude, longitude: longitude)
        }
    }
    
    //MARK: - Set Search Location
    func setSearchLocation(coordinate : CLLocationCoordinate2D){
        removePin()
        getLocationAddressAndAddPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
        destination = coordinate
    }

    //MARK: - IBAction methods
    @IBAction func addLocation() {
        if let destination = destination{
            if editMode {
                if let location = selectedLocation{
                    delegate!.deleteLocation(location: location)
                }
            }
            let place = PlaceObject(title: placeTitle , address: address, coordinate: destination)
            delegate?.setFavoriteLocation(place: place)
        }
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Get address method
    func getLocationAddressAndAddPin(latitude: CLLocationDegrees, longitude : CLLocationDegrees) {

            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = latitude
            center.longitude = longitude

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        if let placemark = placemarks?[0] {
                            
                            self.address = ""
                            
                            if placemark.name != nil {
                                self.address += placemark.name! + " "
                                self.placeTitle = placemark.name! + " "
                            }
                            
                            if placemark.subThoroughfare != nil {
                                self.address += placemark.subThoroughfare! + " "
                            }
                            
                            if placemark.thoroughfare != nil {
                                self.address += placemark.thoroughfare! + "\n"
                            }
                            
                            if placemark.subLocality != nil {
                                self.address += placemark.subLocality! + "\n"
                            }
                            
                            if placemark.locality != nil {
                                self.address += placemark.locality! + "\n"
                            }
                            
                            if placemark.subAdministrativeArea != nil {
                                self.address += placemark.subAdministrativeArea! + "\n"
                            }
                            
                            if placemark.administrativeArea != nil {
                                self.address += placemark.administrativeArea! + "\n"
                            }
                            
                            if placemark.postalCode != nil {
                                self.address += placemark.postalCode! + "\n"
                            }
                            
                            if placemark.country != nil {
                                self.address += placemark.country! + "\n"
                            }
                            
                            self.displayLocation(latitude: latitude, longitude:longitude, title: self.address)
                        }
                  }
            })
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

extension MapViewController: MKMapViewDelegate {
    //MARK: - Annotation view method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        annotationView.animatesWhenAdded = true
        annotationView.markerTintColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        annotationView.image = UIImage(named: "ic_place_2x")
        annotationView.canShowCallout = true
        if editMode {
            annotationView.isDraggable = true
        }else{
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return annotationView
       
    }
    
    //MARK: - Annotion drag methods
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
            if let coordinate = view.annotation?.coordinate{
                setdragLocation(coordinate: coordinate)
            }
            
        default: break
        }
    }
    
    func setdragLocation(coordinate: CLLocationCoordinate2D){
        setSearchLocation(coordinate: coordinate)
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            let anno = view.annotation
            let title = "Location Details"
        let subtitle =  anno?.title as? String
            let alertController = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
    }
    
}
