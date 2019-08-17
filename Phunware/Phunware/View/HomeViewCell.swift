//
//  HomeViewCell.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1        
    }
    var person : Person? {
        didSet {            
            guard let person = person else {
                return
            }
            self.imgView.image = nil
            if let url = person.image {
                UIImage.asyncFrom(url: url) { (result) in
                    switch result {
                    case .success(let image):
                       DispatchQueue.main.async { self.imgView.image = image  }   
                    case .error(let error):
                        print(error)
                        DispatchQueue.main.async {
                            self.imgView.image = UIImage.init(named: "placeholder_nomoon")
                        }                        
                    }
                }
            } else {
                imgView.image = UIImage.init(named: "placeholder_nomoon")
            }
            lblDate?.text = Utils.format(date: person.date ?? "")
            lblTitle?.text = person.title
            lblLocation?.text = person.locationline1
            lblDesc?.text = person.desc
            
        }
    }
}
