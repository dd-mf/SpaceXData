//
//  AppDelegate.swift
//  Demo
//
//  Created by J.Rodden on 4/8/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: configurationForConnecting.role)
    }
}

