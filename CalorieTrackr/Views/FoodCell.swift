//
//  FoodCell.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 21.05.2023.
//

import UIKit
import SwipeCellKit

class FoodCell: SwipeTableViewCell {
    private var foodService = FoodService()
    var deleteAction: (() -> Void)?
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
