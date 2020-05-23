//
//  RelatedAppTableViewCell.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/05/23.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

import UIKit

class RelatedAppTableViewCell: UITableViewCell {
    @IBOutlet weak var appIconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var appDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(cellViewModel: RelatedAppViewController.CellViewModel) {
        appIconImage.image = cellViewModel.image
        title.text = cellViewModel.title
        appDescription.text = cellViewModel.description
    }
}
