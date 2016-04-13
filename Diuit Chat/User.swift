//
//  User.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/6.
//  Copyright © 2016年 duolC. All rights reserved.
//

import Foundation
import DUMessaging

class User {
    static var currentUserId: Int = -1
    static var currentEmail: String = ""
    static var currentUsername: String = ""
    
    static var chats: [DUChat] = []
    
    static func refreshChats(completion:((NSError?) -> Void)) {
        DUMessaging.listChatrooms() { error, chats in
            guard let _:[DUChat] = chats where error == nil else {
                print(error!.localizedDescription)
                completion(error)
                return
            }
            self.chats = chats!
            completion(nil)
            
        }
    }
}