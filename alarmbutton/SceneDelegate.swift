//
//  SceneDelegate.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 25/05/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject
import RubegProtocol_v2_0

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
            let guardService = cacheManager.getGuardService(),
            let phone = cacheManager.getPhone(),
            let password = cacheManager.getPassword(),
            cacheManager.hasCountryCode && cacheManager.hasToken
        {
            DispatchQueue(label: "background_queue", qos: .background).async {
                let addresses = InetAddress.createAll(hosts: guardService.hosts, port: 9010)

                DispatchQueue.main.async {
                    let mainViewController = Container.shared.resolve(
                        MainContract.View.self,
                        arguments: phone, password, addresses, 0
                    )!

                    self.window?.rootViewController = mainViewController
                    self.window?.windowScene = windowScene
                    self.window?.makeKeyAndVisible()
                }
            }
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
