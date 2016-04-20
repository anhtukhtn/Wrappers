//
//  Reachability.swift
//  LeftOrRight
//
//  Created by mac on 4/11/16.
//  Copyright © 2016 LoR. All rights reserved.
//

import Foundation

class ReachabilityWrapper:NSObject {
  
  static private var _shareInstance: ReachabilityWrapper!
  private weak var _alert: UIAlertController?
  var reachability: Reachability?
  
  override init() {
    super.init()
    //declare this inside of viewWillAppear
    do {
      reachability = try Reachability.reachabilityForInternetConnection()
    } catch {
      print("Unable to create Reachability")
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:",name: ReachabilityChangedNotification,object: reachability)
    do{
      try reachability?.startNotifier()
    }catch{
      print("could not start reachability notifier")
    }
  }
  
  static func getInstance() -> ReachabilityWrapper {
    if _shareInstance == nil {
      _shareInstance = ReachabilityWrapper()
    }
    return _shareInstance
  }
  
  private class func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
      return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
  }
  
  class func addReachbilityNoti() {
    ReachabilityWrapper.getInstance()
  }
  
  private class func checkReachability() {
    if isConnectedToNetwork() == false {
      ReachabilityWrapper.getInstance()._alert = AlertView.showAlertOK(
        POPUP_STRING.NO_INTERNET,
        message: POPUP_STRING.CHECK_YOUR_CONNECT) {
          checkReachability()
      }
    }
  }
  
  func reachabilityChanged(note: NSNotification) {
    
    let reachability = note.object as! Reachability
    
    if reachability.isReachable() {
      if _alert != nil {
        _alert?.dismissViewControllerAnimated(false) {
          self._alert = AlertView.showAlertOK(
            POPUP_STRING.CONNECTED,
            message: POPUP_STRING.PLS_REFRESH) {}
        }
      }
      LoadingView.removeLoadingView()
    } else {
      self._alert = AlertView.showAlertOK(
        POPUP_STRING.NO_INTERNET,
        message: POPUP_STRING.CHECK_YOUR_CONNECT) {
          ReachabilityWrapper.checkReachability()
      }
      LoadingView.removeLoadingView()
    }
  }
}
