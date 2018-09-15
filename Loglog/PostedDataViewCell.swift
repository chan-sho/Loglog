//
//  PostedDataViewCell.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/06.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import SVProgressHUD

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
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.05)
        
        contents.isUserInteractionEnabled = true
        relatedURL.isUserInteractionEnabled = true
        secretPass.isUserInteractionEnabled = true
        id.isUserInteractionEnabled = true
        
        // ↓各Labelをタップする事でコピーができるようにする（ここから）
        let tgCategory = UILongPressGestureRecognizer(target: self, action: #selector(PostedDataViewCell.tappedContents(_:)))
        category.addGestureRecognizer(tgCategory)
        
        let tgContents = UILongPressGestureRecognizer(target: self, action: #selector(PostedDataViewCell.tappedContents(_:)))
        contents.addGestureRecognizer(tgContents)
        
        let tgRelatedURL = UILongPressGestureRecognizer(target: self, action: #selector(PostedDataViewCell.tappedrelatedURL(_:)))
        relatedURL.addGestureRecognizer(tgRelatedURL)
        
        let tgSecretPass = UILongPressGestureRecognizer(target: self, action: #selector(PostedDataViewCell.tappedsecretPass(_:)))
        secretPass.addGestureRecognizer(tgSecretPass)
        
        let tgId = UILongPressGestureRecognizer(target: self, action: #selector(PostedDataViewCell.tappedid(_:)))
        id.addGestureRecognizer(tgId)
        // ↑各Labelをタップする事でコピーができるようにする（ここまで）
        
        tgCategory.cancelsTouchesInView = false
        tgContents.cancelsTouchesInView = false
        tgRelatedURL.cancelsTouchesInView = false
        tgSecretPass.cancelsTouchesInView = false
        tgSecretPass.cancelsTouchesInView = false
        tgId.cancelsTouchesInView = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // ↓各Labelをタップする事でコピーができるようにする（ここから）
    @objc func tappedCategory(_ sender:UILongPressGestureRecognizer) {
        UIPasteboard.general.string = category.text
        print("clip board of contents:\(UIPasteboard.general.string!)")
        SVProgressHUD.showSuccess(withStatus: "テキストコピー完了：\n\n\(UIPasteboard.general.string!)")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    @objc func tappedContents(_ sender:UILongPressGestureRecognizer) {
        UIPasteboard.general.string = contents.text
        print("clip board of contents:\(UIPasteboard.general.string!)")
        SVProgressHUD.showSuccess(withStatus: "テキストコピー完了：\n\n\(UIPasteboard.general.string!)")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    @objc func tappedrelatedURL(_ sender:UILongPressGestureRecognizer) {
        UIPasteboard.general.string = relatedURL.text
        print("clip board of relatedURL:\(UIPasteboard.general.string!)")
        SVProgressHUD.showSuccess(withStatus: "テキストコピー完了：\n\n\(UIPasteboard.general.string!)")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    @objc func tappedsecretPass(_ sender:UILongPressGestureRecognizer) {
        UIPasteboard.general.string = secretPass.text
        print("clip board of secretPass:\(UIPasteboard.general.string!)")
        SVProgressHUD.showSuccess(withStatus: "テキストコピー完了：\n\n\(UIPasteboard.general.string!)")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    @objc func tappedid(_ sender:UILongPressGestureRecognizer) {
        UIPasteboard.general.string = id.text
        print("clip board of id:\(UIPasteboard.general.string!)")
        SVProgressHUD.showSuccess(withStatus: "テキストコピー完了：\n\n\(UIPasteboard.general.string!)")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    // ↑各Labelをタップする事でコピーができるようにする（ここまで）
    
    
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
