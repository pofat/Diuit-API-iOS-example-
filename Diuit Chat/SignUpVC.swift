//
//  SignUpVC.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/12.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpVC: UIViewController {
    @IBOutlet var username: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var passwordRepeat: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.username.becomeFirstResponder()
    }
    
    // MARK: action
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doSignUp() {
        guard self.username.text!.isValidUsername() else {
            SVProgressHUD.showErrorWithStatus("Invalid username")
            self.username.becomeFirstResponder()
            return
        }
        
        guard self.email.text!.isValidEmail() else {
            SVProgressHUD.showErrorWithStatus("Invalid email")
            self.email.becomeFirstResponder()
            return
        }
        
        guard self.password.text!.isValidPassword() else {
            SVProgressHUD.showErrorWithStatus("Invalid password")
            self.password.becomeFirstResponder()
            return
        }
        
        guard self.password.text! == self.passwordRepeat.text! else {
            SVProgressHUD.showErrorWithStatus("Password not matched")
            self.passwordRepeat.becomeFirstResponder()
            return
        }
        
        SVProgressHUD.showWithStatus("Loading...")
        let url = "/auth/signup"
        let deviceSerial: String = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? "\(self.username.text!).device.0"
        let params = "username=\(self.username.text!)&password=\(self.password.text!)&email=\(self.email.text!)&deviceSerial=\(deviceSerial)&platform=\(Utility.devicePlatform)"
        Utility.doPostWith(url, params: params) { error, data in
            guard let _:NSData = data where error == nil else {
                SVProgressHUD.showErrorWithStatus("Sign up failed")
                SVProgressHUD.dismissWithDelay(NSTimeInterval(1.0))
                print("error code:\(error!.code)\nreason:\(error!.localizedDescription)")
                return
            }
            SVProgressHUD.dismiss()
            dispatch_async(dispatch_get_main_queue(),{
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        }
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.username {
            self.email.becomeFirstResponder()
        } else if textField == self.email {
            self.password.becomeFirstResponder()
        } else if textField == self.password {
            self.passwordRepeat.becomeFirstResponder()
        } else {
            self.passwordRepeat.resignFirstResponder()
        }
        return true
    }
}

