//
//  AppDelegate.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 25/05/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationService: LocationService!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard #available(iOS 13.0, *) else {
            window = UIWindow(frame: UIScreen.main.bounds)

            locationService = Container.shared.resolve(LocationService.self)!
            locationService.requestAuthorization()

            let cacheManager = Container.shared.resolve(AppDataRepository.self)!

            if
                let company = cacheManager.getCompany(),
                let phone = cacheManager.getPhone(),
                let password = cacheManager.getPassword(),
                cacheManager.hasCountryCode && cacheManager.hasToken
            {
                let mainViewController = Container.shared.resolve(
                    MainContract.View.self,
                    arguments: phone, password, company.ipAddresses, 0
                )!

                window?.rootViewController = mainViewController
                window?.makeKeyAndVisible()
            } else {
                let loginViewController = Container.shared.resolve(LoginContract.View.self)!

                let navigationController =
                    NavigationController(rootViewController: loginViewController)

                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }

            return true
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
