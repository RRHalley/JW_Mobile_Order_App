//
//  AppDelegate.swift
//  JagandwolfOrder
//
//  Created by Ricky Halley
//  Copyright © Jagandwolf All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var pickTimeLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgView.layer.cornerRadius = imgView.bounds.height / 2
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
