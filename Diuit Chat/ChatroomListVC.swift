//
//  ChatroomListVC.swift
//  Diuit API Demo
//
//  Created by David Lin on 11/30/15.
//  Copyright © 2015 Diuit. All rights reserved.
//

import UIKit
import DUMessaging

/**
    This view controller display all chat rooms of current user.
 */
class ChatroomListVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    /**
        Register NSNotification obseerver to receive real time message from Diuit API server.
     */
    func registerMessageObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName("messageReceived", object: nil, queue: NSOperationQueue.mainQueue()) { notif in
            let message = notif.userInfo!["message"] as! DUMessage
            print("Got new message #\(message.id):\(message.data!)\nfrom chat #\(message.chat!.id)")
            User.refreshChats() { error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
                }
            }
            /*
            let targetChat = self.findChatWith(message.chat!.id)
            guard targetChat != nil else {
                print("can't find chatroom of received message")
                return
            }
            // if system message
            if message.mime == "application/diuit-chat-sys-message" {
                User.refreshChats() { error in
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
                    }
                }
            }
            if let targetChat = self.findChatWith(message.chat!.id) {
                targetChat.lastMessage = message
                self.tableView.reloadData()
            }
 */
        }
    }
    
    // MARK: Life Cycle
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatroomSegue" {
            let vc = segue.destinationViewController as! ChatMessagesVC
            vc.chat = User.chats[(self.tableView?.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerMessageObserver()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        User.refreshChats() { error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // MARK: private helper
    /**
        To find trage chat room from current user's chat room list by room id. Return matched instance of DUChat or nil, if not found.
        
        - parameters:
            - id Chat room id
     
     */
    private func findChatWith(id: Int) -> DUChat? {
        
        for chat: DUChat in User.chats {
            if chat.id == id {
                return chat
            }
        }
        return nil
    }
}

// MARK: UITableView Data Source
extension ChatroomListVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let chat = User.chats[indexPath.row] as DUChat
        if let chatName = chat.meta?["name"] as? String {
            c.textLabel?.text = chatName
        } else {
            c.textLabel?.text = "Room \(chat.id)"
        }

        if let lastMessage = chat.lastMessage {
            c.detailTextLabel?.text = lastMessage.createdAt!.messageTimeLabelString
        } else {
            c.detailTextLabel?.text = ""
        }
        return c
    }
}

// MARK: UITableView Delegate
extension ChatroomListVC: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if DUMessaging.currentUser != nil {
            return "Chatrooms of \(User.currentUsername)"
        } else {
            return "Chatrooms"
        }
    }
}