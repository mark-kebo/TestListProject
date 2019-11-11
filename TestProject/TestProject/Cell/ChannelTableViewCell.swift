//
//  ChannelTableViewCell.swift
//  TestProject
//
//  Created by Dmitry Vorozhbicki on 07/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Reusable

class ChannelTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension ChannelTableViewCell {
    public func set(item: Item?) {
        titleLabel.text = item?.title
        descLabel.text = item?.description
        if let url = item?.urlImage {
            APIManager.downloadImage(for: url) { [weak self] (image) in
                self?.thumbnailImageView.image = image
            }
        }
    }
}
