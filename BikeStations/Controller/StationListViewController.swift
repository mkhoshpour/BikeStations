//
//  StationListViewController.swift
//  BikeStations
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import UIKit

protocol MasterVCProtocol {
    func selectedStation(station : BikeStation)
}


class StationListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var filteredStations = [BikeStation]()
    var masterDelegate: MasterVCProtocol?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "StationCell", bundle: nil), forCellReuseIdentifier: "StationCell")
    }
    func updateStations(stations:[BikeStation]){
        self.filteredStations = stations
        self.tableView.reloadData()
    }
    
    // -MARK: UITableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StationCell") as! StationCell
        let currentStation = filteredStations[indexPath.row]
        cell.labelStationName.text = currentStation.name
        cell.labelEmptyDocs.text =  currentStation.capacity + " empty docs"
        cell.labelNumberOfBikes.text = currentStation.capacity + " bikes"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        masterDelegate?.selectedStation(station: filteredStations[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
