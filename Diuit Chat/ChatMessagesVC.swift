//
//  ChatMessagesVC.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/9.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import SDWebImage
import SVProgressHUD
import DUMessaging

class ChatMessagesVC: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chat: DUChat!

    private var messages = [Message]()
    private var avatars:[String: JSQMessagesAvatarImage] = [String: JSQMessagesAvatarImage]()
    private var messageBubbleImageFactory = JSQMessagesBubbleImageFactory()
    private var downloadManager = SDWebImageManager.sharedManager()

    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // register message receiver
        if let chatId = self.chat?.id {
            NSNotificationCenter.defaultCenter().addObserverForName("messageReceived.\(chatId)", object: nil, queue: NSOperationQueue.mainQueue()) { notif in
                guard let _:DUMessage = notif.userInfo!["message"] as? DUMessage else {
                    print("callback return error type")
                    return
                }
                
                let message = notif.userInfo!["message"] as! DUMessage
                NSLog("Got new message #\(message.id) in chat room \(self.chat.id)")
                self.chat.lastMessage = message
                let newMessage = Message(message: message)
                self.messages.append(newMessage)
                self.finishReceivingMessage()
                if message.mime == "application/diuit-chat-sys-message" {
                    // show alert when kicked
                    let json = message.data!.parseJSONString()
                    if let userSerial = json["userId"] as? String {
                        if userSerial == DUMessaging.currentUser?.serial {
                            User.chats.removeAtIndex(User.chats.indexOf(self.chat)!)
                            let alert = UIAlertController(title: "Ohoh!", message: "You are asked to leave here", preferredStyle: .Alert);
                            alert.addAction(UIAlertAction(title: "Got it", style: .Default) { action in
                                self.navigationController?.popViewControllerAnimated(true)
                                })
                            self.presentViewController(alert, animated: true, completion: nil);
                        }
                    }
                }
            }
        }
        // setup JSQMessage UI
        inputToolbar.contentView.leftBarButtonItem = JSQMessagesToolbarButtonFactory.defaultAccessoryButtonItem()
        automaticallyScrollsToMostRecentMessage = true
        
        senderDisplayName = User.currentUsername
        senderId = DUMessaging.currentUser!.serial
        setupTextAvatar(senderDisplayName, incoming: false)
        
        chat.listMessagesBefore() { error, messages in
            guard let _:[DUMessage] = messages where error == nil else {
                print("error:\(error?.localizedDescription)")
                return
            }
            
            for m:DUMessage in messages! {
                self.messages.insert(Message(message:m), atIndex:0)
                self.finishReceivingMessage()
            }

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(ChatroomSettingVC) {
            let vc = segue.destinationViewController as! ChatroomSettingVC
            vc.chat = self.chat
        }
    }

    // MARK: UIImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        var meta:[String: AnyObject] = [String:AnyObject]()
        if let imageName = imageURL.getAssetFullFileName() {
            print("choose image name: \(imageName)")
            meta["name"] = imageName
        }
        meta["senderName"] = User.currentUsername
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true, completion: {
            () -> Void in
        })
        self.chat.sendImage(image, meta: meta, pushMessage: "You've got an image message", pushPayload: nil, badge: "increment") { error, message in
            guard let _:DUMessage = message where error == nil else {
                SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
                print("failed to send image message:\(error!.localizedDescription)")
                return
            }
            
            print("image message #\(message!.id) sent")
        }
    }
    
    // MARK: override JSQMessageViewController - ACTION
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text == "" { return }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        chat.sendText(text, meta: ["senderName":senderDisplayName], pushMessage:"\(senderDisplayName): \(text)") { error, message in
            guard let _:DUMessage = message where error == nil else {
                print(error?.localizedDescription)
                return
            }
            print("message #\(message!.id) sent")
            self.finishSendingMessage()
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            NSLog("Read album error!")
        }
    }
    // MARK: override JSQMessageViewController - collection view delegate and datasource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderSerial == DUMessaging.currentUser!.serial {
            return messageBubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        } else {
            return messageBubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderSerial == DUMessaging.currentUser!.serial { // self
            return avatars[User.currentUsername]
        }
        if let avatar = avatars[message.senderName] {
            return avatar
        } else {
            setupTextAvatar(message.senderName, incoming: true)
            return avatars[message.senderName]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if let mime:String = message.originMessage.mime {
            if mime == "image/jpeg" { // image
                let url = NSURL(string: message.originMessage.data!)
                let cacheKey = SDWebImageManager.sharedManager().cacheKeyForURL(url)
                let cachedImage = SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(cacheKey)
                if cachedImage == nil {
                    self.downloadManager.downloadImageWithURL(url, options: SDWebImageOptions.CacheMemoryOnly, progress: { received, expected in
                        print("received \(received) bytes out of \(expected) bytes from \(url)")
                        }, completed: { image, error, cacheType, finished, imageURL in
                            guard image != nil && finished else {
                                print("errored:\(error?.localizedDescription)")
                                return
                            }
                            print("image completed downloading from \(url)")
                            self.downloadManager.saveImageToCache(image, forURL: imageURL)
                            let photoItem = message.mediaItem as! JSQPhotoMediaItem
                            photoItem.image = image
                            self.collectionView.reloadItemsAtIndexPaths([indexPath])
                    })
                }
            } else if mime == "text/plain" || mime == "application/diuit-chat-sys-message" { // text
                if message.senderSerial == DUMessaging.currentUser!.serial {
                    cell.textView.textColor = UIColor.blackColor()
                } else {
                    cell.textView.textColor = UIColor.whiteColor()
                }
                let attributes: [String: AnyObject] = [NSForegroundColorAttributeName: cell.textView.textColor!, NSUnderlineStyleAttributeName: 1]
                cell.textView.linkTextAttributes = attributes
                
            }
            
        }
        return cell
    }
    
    // view username above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        // sent by me, skip
        if message.senderSerial == DUMessaging.currentUser!.serial {
            return nil
        }
        
        // same sender, skip
        if indexPath.item > 0 {
            let prevMessage = messages[indexPath.item - 1]
            if prevMessage.senderSerial == message.senderSerial {
                return nil
            }
        }

        return NSAttributedString(string: message.senderDisplayName())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        // sent by me, skip
        if message.senderSerial == DUMessaging.currentUser!.serial {
            return CGFloat(0.0)
        }
        
        // same sender, skip
        if indexPath.item > 0 {
            let prevMessage = messages[indexPath.item - 1]
            if prevMessage.senderSerial == message.senderSerial {
                return CGFloat(0.0)
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // MARK: private helper
    func setupTextAvatar(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        var initials: String = ""
        if name.lowercaseString == "system" {
            setupImageAvatar(name, image: UIImage(named:"system-avatar")!, incoming: true)
            return
        } else {
            initials = name.substringToIndex(name.startIndex.advancedBy(1)).uppercaseString
        }
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(20)), diameter: diameter)
        avatars[name] = userImage
    }
    
    func setupImageAvatar(name: String, image: UIImage, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
        avatars[name] = avatarImage
    }

}
