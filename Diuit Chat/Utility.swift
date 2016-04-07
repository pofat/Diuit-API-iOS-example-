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
    
    private static let _serverUrl:String = "https://blueberry-pie-56453.herokuapp.com"
    
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
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        //let textSize = text.sizeWithAttributes([NSFontAttributeName:textFontAttributes])
        //print(" text size at \(textSize.width), \(textSize.height)")
        print("draw bounds: \(size.width), \(size.height)")
        //let drawPoint = CGPointMake(size.width/2 - textSize.width/2, size.height/2 - textSize.height/2)
        //print("draw text at \(drawPoint.x), \(drawPoint.y)")
        text.drawAtPoint(CGPointMake(size.width/2 - 10, size.height/2 - 15), withAttributes: textFontAttributes)
        //text.drawInRect(textRect, withAttributes: textFontAttributes)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}

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
}
