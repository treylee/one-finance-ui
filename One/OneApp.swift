//
//  OneApp.swift
//  One
//
//  Created by Trieveon Cooper on 11/10/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct OneApp: App {
     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


     var body: some Scene {
       WindowGroup {
         NavigationView {
             StripeView()
         }
       }
     }
   }
