//
//  StationCell.swift
//  BikeStations
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {

    @IBOutlet weak var labelStationName: UILabel!
    @IBOutlet weak var labelNumberOfBikes: UILabel!
    @IBOutlet weak var labelEmptyDocs: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
