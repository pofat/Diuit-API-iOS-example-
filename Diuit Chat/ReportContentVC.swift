//
//  ReportContentVC.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/12.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit
import DUMessaging
import SVProgressHUD

class ReportContentVC: UIViewController {
    @IBOutlet var targetUser: UITextField!
    @IBOutlet var reasonTextView: UITextView!
    
    var chat:DUChat? = nil
    
    override func viewDidLoad() {
        print("chat.id = \(chat!.id)")
    }
    
    @IBAction func report() {
        guard self.targetUser.text! != "" else {
            SVProgressHUD.showErrorWithStatus("You must type in username")
            return
        }
        
        guard self.reasonTextView.text! != "" else {
            SVProgressHUD.showErrorWithStatus("You must input reasons")
            return
        }
        
        SVProgressHUD.showWithStatus("Reporting...")
        let params = "reporter=\(User.currentUsername)&targetUser=\(self.targetUser.text!)&chatId=\(self.chat!.id)&reason=\(self.reasonTextView.text!)"
        let url = "/users/report"
        Utility.doPostWith(url, params: params) { error, data in
            guard let _:NSData = data where error == nil else {
                SVProgressHUD.showErrorWithStatus("Request failed")
                return
            }
            SVProgressHUD.dismiss()
            dispatch_async(dispatch_get_main_queue(),{
                self.navigationController?.popViewControllerAnimated(true)
            })
            
        }
        
    }

}
