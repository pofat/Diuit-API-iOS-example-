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
            
            SVProgressHUD.showWithStatus("Loading...")
            DUMessaging.createChatroomWith(userSerials) { error, chat in
                guard let _:DUChat = chat where error == nil else {
                    SVProgressHUD.showErrorWithStatus("Create chat room failed")
                    SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                    print("Create chat error : \(error!.localizedDescription)")
                    return
                }
                
                SVProgressHUD.dismiss()
                User.chats.append(chat!)
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            // do join chat
            guard let _:Int = Int(self.chatRoomId.text!) where self.chatRoomId.text != "" else {
                SVProgressHUD.showErrorWithStatus("Not a valid chat room id")
                return
            }
            
            SVProgressHUD.showWithStatus("Loading...")
            let chatRoomId:Int = Int(self.chatRoomId.text!)!
            DUMessaging.joinChatroomWithId(chatRoomId) { error, chat in
                guard let _:DUChat = chat where error == nil else {
                    SVProgressHUD.showErrorWithStatus("Join chat room failed")
                    SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                    print(error?.localizedDescription)
                    return
                }
                
                SVProgressHUD.dismiss()
                User.chats.append(chat!)
                self.navigationController?.popViewControllerAnimated(true)
            }
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


