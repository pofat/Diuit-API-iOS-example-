//
//  User.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/6.
//  Copyright © 2016年 duolC. All rights reserved.
//

import Foundation
import DUMessaging

/**
    This class saves information of current user.
 */
class User {
    static var currentUserId: Int = -1
    static var currentEmail: String = ""
    static var currentUsername: String = ""
    
    static var chats: [DUChat] = []
    
    /**
        Refresh current user's chat rooms. Noted that user has to be authenticated. You can access NSError in completion closure to check error if there's one.
     */
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