//
//  FacebookWrapper.swift
//  LeftOrRight
//
//  Created by admin on 2/28/16.
//  Copyright © 2016 LoR. All rights reserved.
//

import Foundation


struct FacebookResponse {
  
  private let _dataDict:[String:AnyObject]
  
  func getToken() -> String {
    var tokenResult = ""
    if let token = _dataDict["token"] as? String {
      tokenResult = token
    }
    return tokenResult
  }
  
  func getId() -> String {
    var result = ""
    if let id = _dataDict["id"] as? String {
      result = id
    }
    return result
  }
  
}


class FacebookWrapper {
  
  static private let _requestInfo = ["fields": "id, name, first_name, last_name, picture.type(large), email"]
  
  static private let _readPermissions = [
    "email",
    "user_birthday",
    "user_location",
    "user_work_history",
    "user_friends"]
  
  static func checkLoggedIn() -> FacebookResponse? {
    var fbResponse:FacebookResponse? = nil
    if((FBSDKAccessToken.currentAccessToken()) != nil) {
      let token = FBSDKAccessToken.currentAccessToken().tokenString
      let resultDict = ["token": token]
      fbResponse = FacebookResponse(_dataDict: resultDict)
    }
    return fbResponse
  }
  
// for fbsdk >= 4.6
//  static func loginInViewController(
//    vc:UIViewController,
//    completion:FacebookResponse -> Void)
//  {
//    let fbLoginManager = FBSDKLoginManager()
//    fbLoginManager.loginBehavior = .Native
//    fbLoginManager.logOut()
//    fbLoginManager.logInWithReadPermissions(["email"], fromViewController: vc,
//      handler: {
//        (result, error) in
//        if error == nil {
//          if result.grantedPermissions.contains("email") {
////            getFBUserData(completion)
//            let token = FBSDKAccessToken.currentAccessToken().tokenString
//            let resultDict = ["token": token]
//            let fbResponse = FacebookResponse(_dataDict: resultDict)
//            completion(fbResponse)
//          }
//        }
//    })
//  }
//  
  
  static func loginInViewController(
    fail: () -> Void = {_ in},
    completion:FacebookResponse -> Void)
  {
    let fbLoginManager = FBSDKLoginManager()
    fbLoginManager.loginBehavior = .Native
    fbLoginManager.logOut()
    fbLoginManager.logInWithReadPermissions(_readPermissions,
      handler: {
        (result, error) in
        if error == nil {
          if let grantedPermissions = result.grantedPermissions {
            if grantedPermissions.contains("email") {
              let token = FBSDKAccessToken.currentAccessToken().tokenString
              let resultDict = ["token": token]
              let fbResponse = FacebookResponse(_dataDict: resultDict)
              completion(fbResponse)
            }
            else {
              fail()
            }
          }
          else {
            fail()
          }
        }
    })
  }
 
  static func getFBUserData(completion:FacebookResponse -> Void) {
    if((FBSDKAccessToken.currentAccessToken()) != nil) {
      let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: _requestInfo)
      graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
        if (error == nil){
          if let resultDict = result as? [String:AnyObject] {
            let fbResponse = FacebookResponse(_dataDict: resultDict)
            completion(fbResponse)
          }
        }
      })
    }
  }
  
  static func getFBAvatar(completion:(String) -> Void) {
    getFBUserData() {
      fbresponse in
      let imgURLString = "https://graph.facebook.com/" + fbresponse.getId() + "/picture?type=large" //type=normal
      completion(imgURLString)
    }
  }
  
  static func logout(completion: ()->Void) {
    let fbLoginManager = FBSDKLoginManager()
    fbLoginManager.loginBehavior = .Native
    fbLoginManager.logOut()
    completion()
  }
  
  static func share(
    urlString: String, imageURL: String,
    vc: UIViewController, delegate: FBSDKSharingDelegate) {
    let fbshare = FBSDKShareLinkContent()
    fbshare.contentURL = NSURL(string: urlString)!
    if imageURL != "" {
      fbshare.imageURL = NSURL(string:imageURL)
    }
    FBSDKShareDialog.showFromViewController(vc, withContent: fbshare, delegate: delegate)
  }
}
