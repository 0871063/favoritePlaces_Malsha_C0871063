//
//  LocationSearchTableViewController.swift
//  favoritePlaces_Malsha_C0871063
//
//  Created by Malsha Lambton on 2023-01-24.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {
    
    weak var handleLocationSearchDelegate: HandleMapSearch?
    var matchingLocationItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    //Get Location Address
    func getAddress(placemark:MKPlacemark) -> String {
        
        var address = ""
                
        if placemark.name != nil {
            address += placemark.name! + " "
        }
                
        if placemark.subThoroughfare != nil {
            address += placemark.subThoroughfare! + " "
        }
                
        if placemark.thoroughfare != nil {
            address += placemark.thoroughfare! + "\n"
        }
                
        if placemark.subLocality != nil {
            address += placemark.subLocality! + "\n"
        }
                
        if placemark.subAdministrativeArea != nil {
            address += placemark.subAdministrativeArea! + "\n"
        }
                
        if placemark.postalCode != nil {
            address += placemark.postalCode! + "\n"
        }
                
        if placemark.country != nil {
            address += placemark.country! + "\n"
        }
        
        return address
    }    
}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchText = searchController.searchBar.text else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingLocationItems = response.mapItems
                self.tableView.reloadData()
            }
        }
}

//TableView
extension LocationSearchTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocationItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            let selectedItem = matchingLocationItems[indexPath.row].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = getAddress(placemark: selectedItem)
            return cell
        }else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingLocationItems[indexPath.row].placemark.coordinate
        handleLocationSearchDelegate?.setSearchLocation(coordinate: selectedItem)
        dismiss(animated: true, completion: nil)
    }    
}
