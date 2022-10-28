//
//  ContainerExtensions.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 09.07.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import Swinject
import RubegProtocol_v2_0

extension Container {

    static let shared: Container = {
        let container = Container()

        // MARK: Common

        container.register(AppDataRepository.self) { _ in UserDefaultsAppDataRepository() }
        container.register(GuardServicesGateway.self) { _ in GuardServicesGatewayImpl() }

        container.register(NetworkService.self) { resolver in
            let appDataRepository = resolver.resolve(AppDataRepository.self)!
            return NetworkServiceImpl.createSharedInstance(cacheManager: appDataRepository)
        }

        container.register(LocationService.self) { resolver in
            let networkService = resolver.resolve(NetworkService.self)!
            return LocationServiceImpl(networkService: networkService)
        }

        // MARK: Login

        container.register(LoginContract.Presenter.self) { resolver in
            let appDataRepository = resolver.resolve(AppDataRepository.self)!
            let companiesGateway = resolver.resolve(GuardServicesGateway.self)!
            let networkService = resolver.resolve(NetworkService.self)!

            return LoginPresenter(
                appDataRepository: appDataRepository,
                companiesGateway: companiesGateway,
                networkService: networkService
            )
        }

        container.register(LoginContract.View.self) { resolver in
            let presenter = resolver.resolve(LoginContract.Presenter.self)!
            return LoginViewController(with: presenter)
        }

        // MARK: Password

        let passwordPresenterFactory: (Resolver, String, [InetAddress], Int) -> PasswordContract.Presenter =
            { resolver, phone, addresses, currentAddressIndex in
                let appDataRepository = resolver.resolve(AppDataRepository.self)!
                let networkService = resolver.resolve(NetworkService.self)!

                return PasswordPresenter(
                    appDataRepository: appDataRepository,
                    networkService: networkService,
                    phone: phone,
                    addresses: addresses,
                    currentAddressIndex: currentAddressIndex
                )
            }

        container.register(PasswordContract.Presenter.self, factory: passwordPresenterFactory)

        let passwordViewFactory: (Resolver, String, [InetAddress], Int) -> PasswordContract.View =
            { resolver, phone, addresses, currentAddressIndex in
                let presenter = resolver.resolve(
                    PasswordContract.Presenter.self,
                    arguments: phone, addresses, currentAddressIndex
                )!

                return PasswordViewController(with: presenter)
            }

        container.register(PasswordContract.View.self, factory: passwordViewFactory)

        // MARK: Main

        let mainPresenterFactory: (Resolver, String, String, [InetAddress], Int) -> MainContract.Presenter =
            { resolver, phone, password, addresses, currentAddressIndex in
                let networkService = resolver.resolve(NetworkService.self)!
                let locationService = resolver.resolve(LocationService.self)!
                let appDataRepository = resolver.resolve(AppDataRepository.self)!

                return MainPresenter(
                    appDataRepository: appDataRepository,
                    networkService: networkService,
                    locationService: locationService,
                    phone: phone,
                    password: password,
                    addresses: addresses,
                    currentAddressIndex: currentAddressIndex
                )
            }

        container.register(MainContract.Presenter.self, factory: mainPresenterFactory)

        let mainViewFactory: (Resolver, String, String, [InetAddress], Int) -> MainContract.View =
            { resolver, phone, password, addresses, currentAddressIndex in
                let presenter = resolver.resolve(
                    MainContract.Presenter.self,
                    arguments: phone, password, addresses, currentAddressIndex
                )!

                return MainViewController(with: presenter)
            }

        container.register(MainContract.View.self, factory: mainViewFactory)

        return container
    }()

}
