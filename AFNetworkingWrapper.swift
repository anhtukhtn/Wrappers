//
//  AFNetworkingWrapper.swift
//  BeautyVN
//
//  Created by ANH TU on 1/18/16.
//  Copyright © 2016 Netvis. All rights reserved.
//

import Foundation

class AFNetworkingWrapper {
  
  private static let POST_STRING = "POST"
  private static let FILE_STRING = "file"
  private static let MULTI_FILE_STRING = "file[]"
  
  private static var _afManager:AFURLSessionManager {
    get {
      let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
      let manager = AFURLSessionManager(sessionConfiguration: configuration)
      return manager
    }
  }
  
  static func sendPOSTImageRequest(
    urlString:String,
    imagePath:String,
    paramsDict:Dictionary<String,String>,
    completion:(response: NSURLResponse?, responseObject: AnyObject?, error: NSError?)->Void)
  {
    var paramsSwap = Dictionary<String,String>()
    for param in paramsDict {
      paramsSwap[param.1] = param.0
    }
    
    let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod(POST_STRING,
      URLString:URL_API_IMAGE_UPLOAD,
      parameters: paramsSwap,
      constructingBodyWithBlock: {
        (formData: AFMultipartFormData) -> Void in
        
        do {
          let url = NSURL(string: imagePath)
          try formData.appendPartWithFileURL(url!, name: FILE_STRING)
        }
        catch(_){}
        
        for param in paramsDict {
          let data: NSData = (param.1).dataUsingEncoding(NSUTF8StringEncoding)!
          formData.appendPartWithFormData(data, name: param.0)
        }
        
      }, error: nil)
    
    let uploadTask = _afManager.uploadTaskWithStreamedRequest(
      request,
      progress: nil)
      { (response: NSURLResponse?, responseObject: AnyObject?, error: NSError?) -> Void in
        completion(response: response, responseObject: responseObject, error: error)
    }
    uploadTask.resume()
  }
  
  static func sendPOSTImageRequest(
    urlString:String,
    image:UIImage,
    paramsDict:Dictionary<String,String>,
    completion:(response: NSURLResponse?, responseObject: AnyObject?, error: NSError?)->Void)
  {
    var paramsSwap = Dictionary<String,String>()
    for param in paramsDict {
      paramsSwap[param.1] = param.0
    }
    
    let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod(POST_STRING,
      URLString:URL_API_IMAGE_UPLOAD,
      parameters: nil,
      constructingBodyWithBlock: {
        (formData: AFMultipartFormData) -> Void in
        
        for param in paramsDict {
          let data: NSData = (param.1).dataUsingEncoding(NSUTF8StringEncoding)!
          formData.appendPartWithFormData(data, name: param.0)
        }
        
        if let imageData = UIImagePNGRepresentation(image) {
          formData.appendPartWithFileData(imageData, name: FILE_STRING, fileName: "ios_tu.png", mimeType: "image/png")
        }
        
      }, error: nil)
    
    let uploadTask = _afManager.uploadTaskWithStreamedRequest(
      request,
      progress: nil)
      { (response: NSURLResponse?, responseObject: AnyObject?, error: NSError?) -> Void in
        completion(response: response, responseObject: responseObject, error: error)
    }
    uploadTask.resume()
  }
}