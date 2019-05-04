//
//  ViewController.swift
//  BikeStations
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import PKHUD // This module shows Loading HUD.


class MasterViewController: UIViewController,MasterVCProtocol,GMSMapViewDelegate {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    let searchController = UISearchController(searchResultsController: nil)
    var stations = [BikeStation]()
    var filteredStations = [BikeStation]()
    var listViewController: StationListViewController?
    var tempStation = CLLocationCoordinate2D(latitude: -37.818306, longitude: 144.945923)
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the Search Controller
        self.title = "Bike Station Finder"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search By Station Names"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.loadMapView()
        self.fetchStations()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StationListViewController" {
            listViewController = segue.destination as? StationListViewController
            listViewController!.masterDelegate = self
        }
    }
    
    
    func selectedStation(station : BikeStation){
        self.containerView.isHidden = true
        let destinationLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: station.geocoded_column.coordinates[1], longitude: station.geocoded_column.coordinates[0])
        //mapView.animate(toLocation: destinationLocation)
        mapView.animate(to: GMSCameraPosition(target: destinationLocation, zoom: 20.0, bearing: 0.0, viewingAngle: 0.0))
        
        
    }

    @objc func fetchStations(){
        HUD.show(.progress)
        NetworkHTTPClient.performRequest(HTTPClientEndPoint(method: .get, path: "", body: nil)) { (result) in
            HUD.hide()
            if(result.error == nil){
                self.stations = result.result!
                DispatchQueue.main.async {
                    self.showCircles()
                    //after 15 minutes refresh the data
                    Timer.scheduledTimer(timeInterval: 900,
                                         target: self,
                                         selector: #selector(MasterViewController.fetchStations),
                                         userInfo: nil,
                                         repeats: true)
                }
            }else{
                let alert = UIAlertController(title: "Network Error", message: "Please Try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (action) in
                    self.fetchStations()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // -MARK: Google Maps
    
    func loadMapView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //super.loadView()
        let camera = GMSCameraPosition.camera(withLatitude: -37.818306, longitude: 144.945923, zoom: 15.0)
        //mapView.settings.zoomGestures = true
        self.mapView.camera = camera
        self.mapView.delegate = self
        
        
    }
    
    func showCircles(){
        //Calculate the maximum number of bikes among stations
        let max = Int((stations.max{ $0.capacity < $1.capacity }?.capacity)!)
        //show markers in map
        stations.forEach { (station) in
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: station.geocoded_column.coordinates[1], longitude: station.geocoded_column.coordinates[0])
            marker.title = station.name
            marker.icon = self.makeCircle(size: Float(station.capacity)! / Float(max!))
            marker.icon = self.makeCircle(size: 0.3)
            marker.snippet = "Tap to navigate..."
            marker.map = self.mapView
//            let path = GMSMutablePath()
//            path.add(marker.position)
//            path.add(self.tempStation)
//            let line = GMSPolyline(path: path)
//            line.strokeColor = UIColor(red: CGFloat(Int(station.capacity)!) / 255.0, green: CGFloat(Int(station.capacity)!) / 255.0, blue: 1.0, alpha: 1.0)
//            line.map = self.mapView
            
            self.marker = marker
//            var timer = Timer()
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(moveMarker), userInfo: nil, repeats: true)
//            self.moveMarker(marker)
//            self.tempStation = CLLocationCoordinate2D(latitude: station.coordinates.coordinates[1], longitude: station.coordinates.coordinates[0])
            return
        }
    }
    
    @objc func moveMarker(_ marker : GMSMarker){
        //let marker = self.marker
        //self.tempStation.latitude += 0.0017
        marker.rotation = marker.position.bearing(to: self.tempStation)
        CATransaction.begin()
        CATransaction.setValue(20.0, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        //self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: self.tempStation.latitude, longitude: self.tempStation.longitude, zoom: 15))
        marker.position = CLLocationCoordinate2D(latitude: self.tempStation.latitude, longitude: self.tempStation.longitude)
        CATransaction.commit()
        marker.map = self.mapView
    }
    
    func makeCircle(size : Float) -> UIImage {
        let multiplier = Int(size * 10 + 5)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: multiplier, height: multiplier))
        view.layer.cornerRadius = view.frame.height / 2
        view.backgroundColor = .red
        view.layer.masksToBounds = true
        let image = view.asImage()!
        //let image = UIImage(named: "car-topview")?.resize(withWidth: 40)
        return image
    }
    
    // -MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        // open apple maps for navigations
        let regionDistance:CLLocationDistance = 10000
        let coordinates = marker.position
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = marker.title
        mapItem.openInMaps(launchOptions: options)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    // -MARK: SearchBar Functions
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStations = stations.filter({( station : BikeStation) -> Bool in
            return station.name.lowercased().contains(searchText.lowercased())
        })
        if(filteredStations.count > 0){
            self.containerView.isHidden = false
            self.listViewController?.updateStations(stations: filteredStations)
        }else{
            self.containerView.isHidden = true
        }
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }


}

// Extensions

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension UIView {
    // convert UIView to UIImage
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}

extension UIImage {
    
    func resize(withWidth newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension CLLocationCoordinate2D {
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}
