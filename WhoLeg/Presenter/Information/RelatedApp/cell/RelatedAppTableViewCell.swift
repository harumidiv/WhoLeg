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
    private var appStoreID: String!
    var dawnloadButtonAction: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(cellViewModel: RelatedAppViewController.CellViewModel, buttonAction: ((String) -> Void)?) {
        appIconImage.image = cellViewModel.image
        title.text = cellViewModel.title
        appDescription.text = cellViewModel.description
        appStoreID = cellViewModel.appID
        dawnloadButtonAction = buttonAction
    }

    @IBAction func dawnloadDidTap(_ sender: Any) {
        dawnloadButtonAction?(appStoreID)
    }
}
