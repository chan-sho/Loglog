//
//  PostedDataViewCell.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/06.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit

class PostedDataViewCell: UITableViewCell {
    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var relatedURL: UILabel!
    @IBOutlet weak var secretPass: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mayMapButton: UIButton!
    
    @IBOutlet weak var pincoodinateLatitude: UILabel!
    @IBOutlet weak var pincoodinateLongitude: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData) {
        
        self.category.text = "\(postData.category!)"
        self.contents.text = "\(postData.contents!)"
        self.relatedURL.text = "\(postData.relatedURL!)"
        self.secretPass.text = "\(postData.secretpass!)"
        self.nameLabel.text = "\(postData.name!)"
        
        self.postImageView.image = postData.image
        
        self.pincoodinateLatitude.text = "\(postData.pincoodinateLatitude!)"
        self.pincoodinateLongitude.text = "\(postData.pincoodinateLongitude!)"
        
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
            self.mayMapButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named:"mymap_no")
            self.mayMapButton.setImage(buttonImage, for: .normal)
        }
        
    }
    
}
