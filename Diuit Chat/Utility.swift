//
//  Utility.swift
//  Diuit Chat
//
//  Created by Pofat Diuit on 2016/4/7.
//  Copyright © 2016年 duolC. All rights reserved.
//

import UIKit

public typealias HTTPRequestCallback = (NSError?, NSData?) -> Void

class Utility: NSObject {
    static let devicePlatform: String = "ios_production"
    private static let _serverUrl:String = "https://blueberry-pie-56453.herokuapp.com"
    //private static let _serverUrl:String = "http://localhost:5566"
    
    // MARK: getters
    static var serverUrl:String {
        get {
            return _serverUrl
        }
    }
    
    // MARK: methods
    static func doPostWith(url:String, params: String, extraHeader:[String:AnyObject]? = nil, completion: HTTPRequestCallback) {
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: _serverUrl + url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard let _:NSData = data, let _: NSURLResponse = response where error == nil else {
                completion(error, nil)
                return
            }
            
            if let httpResponse = response as? NSHTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    completion(NSError(domain: "com.diuit.chat.network", code:httpResponse.statusCode, userInfo: ["data": NSString(data: data!, encoding: NSUTF8StringEncoding)!]), nil)
                    return
                }
                
                completion(nil, data)

            } else {
                completion(NSError(domain: "com.diuit.chat.network", code: 499, userInfo:[NSLocalizedDescriptionKey:"No response"]), nil)
                
            }
        }
        task.resume()
    }
    
    static func imageFromText(text:NSString, size:CGSize) -> UIImage {
        let font:UIFont = UIFont(name: "Helvetica Bold", size: 30)!
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
        
        // TODO: make text center
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        text.drawAtPoint(CGPointMake(size.width/2 - 10, size.height/2 - 15), withAttributes: textFontAttributes)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}

// MARK: String extension
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
    
    func isValidUsername() -> Bool {
        let pattern = "^[a-z0-9_]{3,16}$"
        let test = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return test.evaluateWithObject(self)
    }
    
    func isValidEmail() -> Bool {
        let pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        let test = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return test.evaluateWithObject(self)
    }
    
    func isValidPassword() -> Bool {
        let pattern = "^[a-zA-Z0-9_-]{4,18}$"
        let test = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return test.evaluateWithObject(self)
    }
}

// MARK: NSURL extension
extension NSURL {
    func getAssetFullFileName() -> String? {
        guard self.scheme == "assets-library" else {
            return nil
        }
        let absoluePath = self.absoluteString
        let idRange = absoluePath.rangeOfString("id=")
        let extRange = absoluePath.rangeOfString("&ext=")
        let fileName = absoluePath.substringWithRange(idRange!.endIndex..<extRange!.startIndex)
        let ext = absoluePath.substringWithRange(extRange!.endIndex..<absoluePath.endIndex)
        return fileName+"."+ext
    }
    
    func getAssetFileExt() -> String? {
        guard self.scheme == "assets-library" else {
            return nil
        }
        let absoluePath = self.absoluteString
        let extRange = absoluePath.rangeOfString("&ext=")
        return absoluePath.substringWithRange(extRange!.endIndex..<absoluePath.endIndex)
    }
    
    func getAssetFileName() -> String? {
        guard self.scheme == "assets-library" else {
            return nil
        }
        let absoluePath = self.absoluteString
        let idRange = absoluePath.rangeOfString("id=")
        let extRange = absoluePath.rangeOfString("&ext=")
        return absoluePath.substringWithRange(idRange!.endIndex..<extRange!.startIndex)
    }
}