//
//  SceneDelegate.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 25/05/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var locationService: LocationService!

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

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
            window?.windowScene = windowScene
            window?.makeKeyAndVisible()
        } else {
            let loginViewController = Container.shared.resolve(LoginContract.View.self)!

            let navigationController =
                NavigationController(rootViewController: loginViewController)

            window?.rootViewController = navigationController
            window?.windowScene = windowScene
            window?.makeKeyAndVisible()
        }
    }

}
