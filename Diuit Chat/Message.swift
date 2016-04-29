//
//  Message.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/9.
//  Copyright © 2016年 duolC. All rights reserved.
//

import Foundation
import DUMessaging
import JSQMessagesViewController
import SDWebImage

/// This class is to make DUMessage instances conform to JSQMessageData protocol
class Message: NSObject, JSQMessageData {
    /// The oirignal DUMessage instance from Diuit API server
    let originMessage: DUMessage
    let mediaItem: JSQMediaItem
    var senderSerial: String
    var senderName: String
    
    init(message:DUMessage) {
        self.originMessage = message

        if let sender = message.senderUser { // message from user
            self.senderSerial = sender.serial
            
            if let meta:[String:AnyObject] = message.meta {
                if let name = meta["senderName"] as? String {
                    self.senderName = name
                } else {
                    self.senderName = sender.serial
                }
            } else {
                self.senderName = sender.serial
            }
        } else { // XXX: system messages have no sender value
            self.senderSerial = "System"
            self.senderName = "System"
        }
        
        if let mime = self.originMessage.mime {
            if mime == "image/jpeg" {
                let url = NSURL(string:self.originMessage.data!)
                let cacheKey = SDWebImageManager.sharedManager().cacheKeyForURL(url)
                let cachedImage = SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(cacheKey)
                mediaItem = JSQPhotoMediaItem.init(image: cachedImage)
            } else {
                mediaItem = JSQPhotoMediaItem.init()
            }
        } else {
            mediaItem = JSQMediaItem.init()
        }
        super.init()
    }
    
    // MARK: JSQMessageData protocol
    func senderId() -> String! {
        return senderSerial
    }
    
    func senderDisplayName() -> String! {
        return senderName
    }
    
    func date() -> NSDate! {
        return self.originMessage.createdAt
    }
    
    func isMediaMessage() -> Bool {
        if self.originMessage.mime == "text/plain" {
            return false
        } else if self.originMessage.mime == "application/diuit-chat-sys-message" {
            return false
        } else {
            return true
        }
    }
    
    func  messageHash() -> UInt {
        return UInt(self.originMessage.id)
    }
    
    // MARK: optional protocol
    func text() -> String! {
        if !self.isMediaMessage() {
            return self.originMessage.data!
        } else {
            return ""
        }
    }
    
    func media() -> JSQMessageMediaData! {
        return mediaItem
        
    }
    
}