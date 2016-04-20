//
//  GCMWrapper.swift
//  LeftOrRight
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 LoR. All rights reserved.
//

import Foundation

class GCMWrapper {
  static private func subscribeToTopic(topic: String, registrationToken: String?) {
    // If the app has a registration token and is connected to GCM, proceed to subscribe to the
    // topic
    if(registrationToken != nil ) {
      GCMPubSub.sharedInstance().subscribeWithToken(registrationToken, topic: topic,
        options: nil, handler: {(error:NSError?) -> Void in
          if let error = error {
            // Treat the "already subscribed" error more gently
            if error.code == 3001 {
              print("Already subscribed to \(topic)")
            } else {
              print("Subscription failed: \(error.localizedDescription)");
            }
          } else {
            NSLog("Subscribed to \(topic)");
          }
      })
    }
  }
  
  static func connectAndSubcribeTopic(topic: String, registrationToken: String?) {
    GCMService.sharedInstance().connectWithHandler({
      (error) -> Void in
      if error != nil {
        print("Could not connect to GCM: \(error.localizedDescription)")
      } else {
        print("Connected to GCM")
        // ...
        subscribeToTopic(topic, registrationToken: registrationToken)
      }
    })
  }
  
}
