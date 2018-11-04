//
//  RequestAndAnswerTableViewCell.swift
//  Loglog
//
//  Created by 高野翔 on 2018/11/04.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit

class RequestAndAnswerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var answerCategory: UILabel!
    @IBOutlet weak var requestTextField: UILabel!
    @IBOutlet weak var answerTextField: UILabel!
    @IBOutlet weak var time: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setPostData2(_ postData: PostData) {
        
        self.answerCategory.text = "\(postData.answerCategory!)"
        self.requestTextField.text = "\(postData.requestTextField!)"
        self.answerTextField.text = "\(postData.answerTextField!)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: postData.date!)
        self.time.text = dateString
    }
}
