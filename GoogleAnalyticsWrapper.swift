//
//  GoogleAnalyticsWrapper.swift
//  LeftOrRight
//
//  Created by admin on 3/4/16.
//  Copyright © 2016 LoR. All rights reserved.
//

import Foundation

class GoogleAnalyticsWrapper {
  
  static private func setupUncaughtExceoptionsTracking() {
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true
    gai.logger.logLevel = GAILogLevel.None
  }
  
  static func startTrackingWithTrackingID(trackingID:String) {
    GAI.sharedInstance().trackerWithTrackingId(trackingID)
    setupUncaughtExceoptionsTracking()
  }
  
  static func sendScreenName(screenName: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: screenName)
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }
}
