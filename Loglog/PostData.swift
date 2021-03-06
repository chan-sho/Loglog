//
//  PostData.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/06.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class PostData: NSObject {
    
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var category: String?
    var contents: String?
    var relatedURL: String?
    var secretpass: String?
    var pincoodinateLatitude: Double?
    var pincoodinateLongitude: Double?
    var pinAddress: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var EULAagreement: String?
    var requestTextField: String?
    var requestUserEmail: String?
    var answerTextField: String?
    var answerCategory: String?
    var answerFlag: String?
    
    
    //自分だけの地図にするかどうかのボタン
    var myMap: [String] = []
    var myMapSelected: Bool = false
    
    var userID: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        imageString = valueDictionary["image"] as? String
        if imageString != nil {
        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        }
        
        self.name = valueDictionary["name"] as? String
        self.category = valueDictionary["category"] as? String
        self.contents = valueDictionary["contents"] as? String
        self.relatedURL = valueDictionary["relatedURL"] as? String
        self.secretpass = valueDictionary["secretpass"] as? String
        self.userID = valueDictionary["userID"] as? String
        
        self.pincoodinateLatitude = valueDictionary["pincoodinateLatitude"] as? Double
        self.pincoodinateLongitude = valueDictionary["pincoodinateLongitude"] as? Double
        self.pinAddress = valueDictionary["pinAddress"] as? String
        self.EULAagreement = valueDictionary["EULAagreement"] as? String
        self.requestTextField = valueDictionary["requestTextField"] as? String
        self.requestUserEmail = valueDictionary["requestUserEmail"] as? String
        self.answerTextField = valueDictionary["answerTextField"] as? String
        self.answerCategory = valueDictionary["answerCategory"] as? String
        self.answerFlag = valueDictionary["answerFlag"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in self.likes {
            if likeId == myId {
                self.isLiked = true
                break
            }
        }
        
        if let myMap = valueDictionary["myMap"] as? [String] {
            self.myMap = myMap
        }
        
        for myMapId in self.myMap {
            if myMapId == myId {
                self.myMapSelected = true
                break
            }
            else {
                self.myMapSelected = false
                break
            }
        }
    }
}
