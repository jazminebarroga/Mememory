//
//  AppDelegate.swift
//  MemoryGame
//

import UIKit
import MemoryGameUIKit
import MemoryGameMain

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let container = AppDependencyContainer()

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mainVC = container.makeGameViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = mainVC
        return true
    }

}

