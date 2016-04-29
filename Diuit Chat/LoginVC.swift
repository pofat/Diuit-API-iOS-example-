//
//  LoginVC.swift
//  diuitchat
//
//  Created by Pofat Diuit on 2016/3/25.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import SVProgressHUD
import DUMessaging

class LoginVC: UIViewController {
    var autoLogin = false
    var autoUsername = ""
    var autoPassword = ""

    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if autoLogin { // do auto login (after sign up)
            dispatch_async(dispatch_get_main_queue(), {
                self.userName.text = self.autoUsername
                self.password.text = self.autoPassword
                self.doLogin()
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SignUpVC {
            vc.delegate = self
        }
    }
    
    @IBAction func doLogin() {
        guard self.userName!.text! != "" else {
            self.userName!.becomeFirstResponder()
            SVProgressHUD.showInfoWithStatus("Username can not be empty")
            return
        }
        
        guard self.password!.text! != "" else {
            self.password!.becomeFirstResponder()
            SVProgressHUD.showInfoWithStatus("Password can not be empty")
            return
        }
        
        SVProgressHUD.showWithStatus("Loading...")
        let url = "/auth/signin"
        let params = "username=\(self.userName!.text!)&password=\(self.password!.text!)&deviceSerial=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)&platform=\(Utility.devicePlatform)"
        Utility.doPostWith(url, params: params) { error, data in
            guard let _:NSData = data where error == nil else {
                SVProgressHUD.showErrorWithStatus("Login failed")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                print("error code:\(error!.code)\nreason:\(error!.localizedDescription)")
                return
            }
            let json: [String: AnyObject]
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
            } catch {
                SVProgressHUD.showErrorWithStatus("Login failed")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                return
            }
            if let session = json["session"] as? String {
                
                /**
                    [Diuit API] Before using all Diuit features, you have to authenticate your device with a session token.
                 */
                DUMessaging.loginWithAuthToken(session) { error, result in
                    
                    guard error == nil else {
                        SVProgressHUD.showErrorWithStatus("Login failed")
                        SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                        print(error!.localizedDescription)
                        return
                    }
                    
                    let userDict = json["user"] as! [String:AnyObject]
                    User.currentEmail = userDict["email"] as! String
                    User.currentUsername = self.userName!.text!
                    User.currentUserId = userDict["id"] as! Int
                    
                    /**
                        [Diuit API] List all chat rooms of current user
                     */
                    DUMessaging.listChatrooms() { error, chats in
                        guard let _:[DUChat] = chats where error == nil else {
                            SVProgressHUD.showErrorWithStatus("Login failed")
                            SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                            print(error!.localizedDescription)
                            return
                        }
                        
                        User.chats = chats!
                        SVProgressHUD.dismiss()
                        self.performSegueWithIdentifier("chatListSegue", sender: nil)
                    }
                }
            } else {
                SVProgressHUD.showErrorWithStatus("Login failed")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                return
            }
        }
    }

}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == userName {
            password.becomeFirstResponder()
        } else {
            self.doLogin()
        }
        return true
    }
}


