//
//  FoodCell.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 21.05.2023.
//

import UIKit

class FoodCell: UITableViewCell {
    
    private var foodService = FoodService()
    var deleteAction: (() -> Void)?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        button.isHidden = !selected
    }
    
    @IBAction func butonPressed(_ sender: UIButton) {
        deleteAction?()
    }
    
}
