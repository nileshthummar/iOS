//
//  DetailViewController.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var viewModel : DetailViewModel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.imgView.layer.cornerRadius = 15
            self.imgView.clipsToBounds = true
            self.imgView.layer.borderColor = UIColor.black.cgColor
            self.imgView.layer.borderWidth = 1
        }
        setData()
        checkForFavorite()
    }    
    func setData(){
        lblTitle.text = viewModel.getTitle()        
        imgView.sd_setImage(with: URL(string: viewModel.getImageUrl()))
        lblLocation?.text = viewModel.getLocation()
        lblTime?.text = viewModel.getTime()        
    }
    func updateLayout() {
        let maxWidth = self.view.bounds.width - 30
        let textSize = Utils.getTextSize(lblTitle, width: maxWidth)
        lblTitle.frame = CGRect(x: 15, y: 15, width: maxWidth, height: textSize.height)
    }
    @IBAction func favoriteClick(sender: AnyObject){
        favoriteUpdate()
    }
    ///Check if Saved by user? button will be red else gray
    func checkForFavorite() {
        if FavotireManager.shared.check(id: viewModel.event.id) {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        }
    }
    ///Update Favorite in User default and change button color
    func favoriteUpdate() {
        if FavotireManager.shared.check(id: viewModel.event.id) {
            FavotireManager.shared.remove(id: viewModel.event.id)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        } else {
            FavotireManager.shared.add(id: viewModel.event.id)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
    }
}

