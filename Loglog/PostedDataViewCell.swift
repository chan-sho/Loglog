//
//  PostedDataViewCell.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/06.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit

class PostedDataViewCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var relatedURL: UILabel!
    @IBOutlet weak var secretPass: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myMapButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData) {
        
        self.id.text = "\(postData.self.id!)"
        self.category.text = "\(postData.category!)"
        self.contents.text = "\(postData.contents!)"
        self.relatedURL.text = "\(postData.relatedURL!)"
        self.secretPass.text = "\(postData.secretpass!)"
        self.nameLabel.text = "\(postData.name!)"
        
        self.postImageView.image = postData.image
        
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        if postData.isLiked {
            let buttonImage = UIImage(named:"like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named:"like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        if postData.myMapSelected {
            let buttonImage = UIImage(named:"mymap_yes")
            self.myMapButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named:"mymap_no")
            self.myMapButton.setImage(buttonImage, for: .normal)
        }
        
    }
    
}
