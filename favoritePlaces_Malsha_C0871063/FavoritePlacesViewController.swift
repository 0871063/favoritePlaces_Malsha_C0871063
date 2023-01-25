//
//  ViewController.swift
//  favoritePlaces_Malsha_C0871063
//
//  Created by Malsha Lambton on 2023-01-24.
//

import UIKit
import CoreData

class FavoritePlacesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var locations = [Location]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
        // Do any additional setup after loading the view.
    }
    //MARK: - Database methods
    func deleteLocation(location: Location) {
        context.delete(location)
    }
    
    func saveLocations() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func loadLocations() {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
        do {
            locations = try context.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Navigation method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MapViewController {
            destination.delegate = self
            
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.selectedLocation = locations[index]
                }
            }
        }
    }

}

//MARK: - TableView Delegate method
extension FavoritePlacesViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        let location = locations[indexPath.row]
        cell.titleLable.text = location.title
        cell.addressLabel.text = location.address
        cell.latitudeLabel.text = "Longitude : \(location.longitude)"
        cell.longitudeLable.text = "Latitude : \(location.latitude)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteLocation(location: locations[indexPath.row])
            saveLocations()
            locations.remove(at: indexPath.row)
            loadLocations()
            
        } else if editingStyle == .insert {

        }
    }
}

//MARK: - MapView Delegate method
extension FavoritePlacesViewController: MapViewDelegate {
    func setFavoriteLocation(place : PlaceObject){
        locations = []
        let selectedLocation = Location(context: context)
        selectedLocation.latitude = place.coordinate.latitude
        selectedLocation.longitude = place.coordinate.longitude
        selectedLocation.address = place.address
        selectedLocation.title = place.title
        saveLocations()
        loadLocations()
        
    }
}
