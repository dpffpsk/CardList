//
//  CardListCell.swift
//  CreditCardList
//
//  Created by 이니텍 on 2021/12/14.
//

import UIKit

class CardListCell: UITableViewCell {

    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var promotionLabel: UILabel!
    @IBOutlet var cardNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
