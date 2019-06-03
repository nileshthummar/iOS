//
//  HomeTableViewCell.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit
import SDWebImage

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewFav: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imgView.layer.cornerRadius = 15
            self.imgView.clipsToBounds = true
            self.imgView.layer.borderColor = UIColor.black.cgColor
            self.imgView.layer.borderWidth = 1
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    var event: Event! {
        didSet {
            lblTitle?.text = event.title
            imgView.image = nil;            
            if ((event.performers?.first?.image) != nil){
                imgView.sd_setImage(with: URL(string: event.performers?.first?.image ?? ""))
            }
            lblLocation?.text = "\(String(describing: event.vanueDetail?.city ?? "--")) , " + "\(String(describing: event.vanueDetail?.state ?? "--"))"
            lblTime?.text = Utils.format(date: event.datetime_utc ?? "")
            if FavotireManager.shared.check(id: event.id) {
                imgViewFav.isHidden = false
            } else {
                imgViewFav.isHidden = true
            }
        }
    }
}
