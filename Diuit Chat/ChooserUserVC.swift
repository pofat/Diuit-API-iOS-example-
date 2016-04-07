//
//  ChooserUserVC.swift
//  Diuit API Demo
//
//  Created by Pofat Diuit on 2015/12/24.
//  Copyright © 2015年 Diuit. All rights reserved.
//

import UIKit
import DUMessaging
import SVProgressHUD

class ChooserUserVC: UIViewController {
    @IBOutlet var otherUsername: UITextField!
    @IBOutlet var chatRoomId: UITextField!
    @IBOutlet var usersTextView: UITextView!
    @IBOutlet var createBtn: UIBarButtonItem!
    
    private var userArray:[String: String] = [String:String]()
    private var isCreateChat = true
    
    
    @IBAction func createOrJoinChat() {
        if isCreateChat {
            // do create chat
            guard self.userArray.count > 0 else {
                SVProgressHUD.showInfoWithStatus("You must add at lease one user")
                return
            }
            
            var userSerials:[String] = []
            for (_, email) in self.userArray {
                if !userSerials.contains(email) {
                    userSerials.append(email)
                }
            }
            
            DUMessaging.createChatroomWith(userSerials) { error, chat in
                guard let _:DUChat = chat where error == nil else {
                    SVProgressHUD.showErrorWithStatus("Create chat room failed")
                    print("Create chat error : \(error!.localizedDescription)")
                    return
                }
                
                User.chats.append(chat!)
            }
        } else {
            // do join chat
        }
    }
    
    @IBAction func searchUserAndAppend() {
        guard self.otherUsername.text! != "" else {
            SVProgressHUD.showInfoWithStatus("Username can not be empty")
            self.otherUsername.becomeFirstResponder()
            return
        }
        
        guard self.otherUsername.text! != User.currentUsername else {
            SVProgressHUD.showInfoWithStatus("This is yourself")
            self.otherUsername.text = ""
            self.otherUsername.becomeFirstResponder()
            return
        }
        
        guard !self.userArray.keys.contains(self.otherUsername.text!) else {
            SVProgressHUD.showInfoWithStatus("User already in the list")
            self.otherUsername.text = ""
            self.otherUsername.becomeFirstResponder()
            return
        }
        
        SVProgressHUD.showWithStatus("Loading...")
        
        let url: String = "/users/queryEmail"
        let params: String = "username=\(self.otherUsername.text!)"
        Utility.doPostWith(url, params: params) { error, data in
            
            guard let _:NSData = data where error == nil else {
                SVProgressHUD.showErrorWithStatus("User not found")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                print("error code:\(error!.code)\nreason:\(error!.localizedDescription)")
                return
            }
            
            let json: [String: AnyObject]
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
            } catch {
                SVProgressHUD.showErrorWithStatus("User not found")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                return
            }
            SVProgressHUD.dismiss()
            self.userArray[self.otherUsername.text!] = json["email"] as! String
            print(json["email"]!)
            dispatch_async(dispatch_get_main_queue(),{
                self.usersTextView.text = self.usersTextView.text! + " \(self.otherUsername.text!)"
                self.otherUsername.text = ""
            })
            
        }
    }
}

extension ChooserUserVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1 {
            self.createBtn.title = "Join Chat"
            isCreateChat = false
        } else {
            self.createBtn.title = "Create Chat"
            isCreateChat = true
        }
    }
}
/*
    @IBOutlet var tableView: UITableView!
    @IBOutlet var joinButton: UIBarButtonItem!
    
    private var doJoinRoom: Bool = false
    private let userDict: NSDictionary = [
        //"1234":"User1",
        //"2345":"User2",
        "demouser1":"demouser1",
        "demouser2":"demouser2",
        "demouser3":"demouser3"]
        //"diuitapitestuser0":"BEN",
        //"diuitapitestuser1":"CHRIS",
        //"diuitapitestuser2":"MIRU",
        //"diuitapitestuser3":"POFAT",
        //"diuitapitestuser4":"MOMO"]
    private var filteredDict: NSMutableDictionary?
    private let roomDict: [String:Int] = ["join me":10]
    private var selected: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        filteredDict = NSMutableDictionary(dictionary: userDict)
        filteredDict!.removeObjectForKey((DUMessaging.currentUser?.serial)!)

        self.tableView.allowsMultipleSelection = true
        self.tableView.reloadData()
    }
    
    @IBAction func join() {
        if self.doJoinRoom {
            let chatId:Int = 10
            DUMessaging.joinChatroomWithId(chatId) {error, chat in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    NSLog("error joining chat: \(error!.localizedDescription)")
                }
            }
        } else {
            if selected.count != 0 {
                DUMessaging.createChatroomWith(selected) {error, chat in
                    if error == nil {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        NSLog("error creating chat: \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
}

extension ChooserUserVC: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (self.filteredDict != nil) ? (self.filteredDict?.count)! : 0
        } else {
            return self.roomDict.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let keys = self.filteredDict?.allKeys
        if indexPath.section == 0 {
            c.textLabel!.text = self.filteredDict?.valueForKey(keys![indexPath.row] as! String) as? String
            if ((selected.indexOf((c.textLabel!.text)!)) != nil) {
                c.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                c.accessoryType = UITableViewCellAccessoryType.None
            }
        } else {
            c.textLabel!.text = "join me"
            if ((selected.indexOf((c.textLabel!.text)!)) != nil) {
                c.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                c.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        return c
    }
}

extension ChooserUserVC: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Create chat with friends"
        } else {
            return "Join other room"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            self.joinButton.title = "Create Chat"
            self.doJoinRoom = false
            let roomIndex = selected.indexOf("join me")
            if roomIndex != nil {
                selected.removeAtIndex(roomIndex!)
            }

            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            if let index = selected.indexOf((cell?.textLabel!.text)!) {
                selected.removeAtIndex(index)
            } else {
                selected.append((cell?.textLabel!.text)!)
            }
        } else {
            self.joinButton.title = "Join Chat"
            self.doJoinRoom = true
            selected.removeAll()
            selected.append("join me")
        }
        self.tableView.reloadData()
    }
 */


