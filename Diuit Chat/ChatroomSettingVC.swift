//
//  ChatroomSettingVC.swift
//  Diuit API Demo
//
//  Created by Pofat Diuit on 2015/12/24.
//  Copyright © 2015年 Diuit. All rights reserved.
//

import UIKit
import DUMessaging
import SVProgressHUD

class ChatroomSettingVC: UIViewController {

    @IBOutlet var idLabel: UILabel!
    @IBOutlet var roomNameText: UITextField!
    @IBOutlet var tableView: UITableView!

    var chat:DUChat!
    var serials:[String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.serials = self.chat.members!
        let index = self.serials.indexOf((DUMessaging.currentUser?.serial)!)
        self.serials.removeAtIndex(index!)
        
        self.idLabel.text = "Chat ID: \(self.chat.id)"
        self.roomNameText.text = (self.chat.meta!["name"] != nil) ? self.chat.meta!["name"] as! String : "room \(chat.id)"
        // Do any additional setup after loading the view.
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .None
        self.tableView.reloadData()
    }

    @IBAction func save() {
        if self.roomNameText.text != "" {
            self.chat.updateMeta(["name": self.roomNameText.text!]) { error, chat in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            let alert = UIAlertController(title: "Info", message: "Room name can not be empty", preferredStyle: .Alert);
            presentViewController(alert, animated: true, completion: nil);
        }
    }

    @IBAction func leaveRoom() {
        SVProgressHUD.showWithStatus("Loading...")
        self.chat.leaveOnCompletion() { error, message in
            guard error == nil else {
                SVProgressHUD.showErrorWithStatus("Leave chat room failed")
                print(error?.localizedDescription)
                return
            }
            
            SVProgressHUD.dismiss()
            let vcs = self.navigationController?.viewControllers
            for vc in vcs! {
                if vc.isKindOfClass(ChatroomListVC) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
}

extension ChatroomSettingVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serials.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let serialLabel = c.viewWithTag(1) as! UILabel
        let kickBtn = c.viewWithTag(2) as! UIButton
        serialLabel.text = self.serials[indexPath.row]
        kickBtn.addTarget(self, action: #selector(ChatroomSettingVC.kick(_:)), forControlEvents: .TouchUpInside)
        return c
    }
    
    func kick(sender: UIButton!) {
        if (((sender.superview?.superview?.isKindOfClass(UITableViewCell))) != nil) {
            let indexPath = self.tableView.indexPathForCell(sender.superview?.superview as! UITableViewCell)
            NSLog("kick \(self.serials[indexPath!.row])")
            self.chat.kickUser(self.serials[indexPath!.row]) {error, message in
                if error != nil {
                    NSLog("error kicking due to : \(error!.localizedDescription)")
                } else {
                    self.chat.removeMemberWith(self.serials[indexPath!.row])
                    self.serials.removeAtIndex(indexPath!.row)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}

extension ChatroomSettingVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("select \(indexPath.row) row")
    }

}
