//
//  ChatroomListVC.swift
//  Diuit API Demo
//
//  Created by David Lin on 11/30/15.
//  Copyright © 2015 Diuit. All rights reserved.
//

import UIKit
import DUMessaging

class ChatroomListVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    func registerMessageObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName("messageReceived", object: nil, queue: NSOperationQueue.mainQueue()) { notif in
            let message = notif.userInfo!["message"] as! DUMessage
            NSLog("Got new message #\(message.id):\(message.data!)\nfrom chat #\(message.chat!.id)")
            let targetChat = self.findChatWith(message.chat!.id)
            guard targetChat != nil else {
                NSLog("can't find chatroom of received message")
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
        }
    }
    
    // MARK: Life Cycle
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatroomSegue" {
            //let vc = segue.destinationViewController as! ChatroomVC
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
    private func findChatWith(id: Int) -> DUChat? {
        
        for chat: DUChat in User.chats {
            if chat.id == id {
                return chat
            }
        }
        return nil
    }
}

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

        if chat.lastMessage?.mime == "text/plain" {
            c.detailTextLabel?.text = chat.lastMessage?.data
        } else if chat.lastMessage != nil {
            c.detailTextLabel?.text = ""
        } else {
            c.detailTextLabel?.text = ""
        }
        return c
    }
}

extension ChatroomListVC: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if DUMessaging.currentUser != nil {
            return "Chatrooms of \(User.currentUsername)"
        } else {
            return "Chatrooms"
        }
    }
}

extension String {
    func parseJSONString() -> [String: AnyObject] {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding){
            do{
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject]{
                    return dictionary
                }
            }catch {
                print("error")
            }
        }
        return [String: AnyObject]()
    }
}