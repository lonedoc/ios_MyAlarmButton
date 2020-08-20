//
//  ContainerExtensions.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 09.07.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import Swinject

extension Container {

    static let shared: Container = {
        let container = Container()

        // MARK: Common

        container.register(CacheManager.self) { _ in UserDefaultsCacheManager() }
        container.register(CompaniesGateway.self) { _ in CompaniesTcpGateway() }

        container.register(NetworkService.self) { resolver in
            let cacheManager = resolver.resolve(CacheManager.self)!
            return NetworkServiceImpl.createSharedInstance(cacheManager: cacheManager)
        }

        container.register(LocationService.self) { resolver in
            let networkService = resolver.resolve(NetworkService.self)!
            return LocationServiceImpl(networkService: networkService)
        }

        // MARK: Login

        container.register(LoginContract.Presenter.self) { resolver in
            let cacheManager = resolver.resolve(CacheManager.self)!
            let companiesGateway = resolver.resolve(CompaniesGateway.self)!
            let networkService = resolver.resolve(NetworkService.self)!

            return LoginPresenter(
                cacheManager: cacheManager,
                companiesGateway: companiesGateway,
                networkService: networkService
            )
        }

        container.register(LoginContract.View.self) { resolver in
            let presenter = resolver.resolve(LoginContract.Presenter.self)!
            return LoginViewController(with: presenter)
        }

        // MARK: Password

        let passwordPresenterFactory: (Resolver, String, [String], Int) -> PasswordContract.Presenter = {
            resolver, phone, ipAddresses, initialIpIndex in
                let cacheManager = resolver.resolve(CacheManager.self)!
                let networkService = resolver.resolve(NetworkService.self)!

                return PasswordPresenter(
                    cacheManager: cacheManager,
                    networkService: networkService,
                    phone: phone,
                    ipAddresses: ipAddresses,
                    currentIpIndex: initialIpIndex
                )
            }

        container.register(PasswordContract.Presenter.self, factory: passwordPresenterFactory)

        let passwordViewFactory: (Resolver, String, [String], Int) -> PasswordContract.View = {
            resolver, phone, ipAddresses, initialIpIndex in
                let presenter = resolver.resolve(
                    PasswordContract.Presenter.self,
                    arguments: phone, ipAddresses, initialIpIndex
                )!

                return PasswordViewController(with: presenter)
            }

        container.register(PasswordContract.View.self, factory: passwordViewFactory)

        // MARK: Main

        let mainPresenterFactory: (Resolver, String, String, [String], Int) -> MainContract.Presenter = {
            resolver, phone, password, ipAddresses, initialIpIndex in
                let networkService = resolver.resolve(NetworkService.self)!
                let locationService = resolver.resolve(LocationService.self)!
                let cacheManager = resolver.resolve(CacheManager.self)!

                return MainPresenter(
                    cacheManager: cacheManager,
                    networkService: networkService,
                    locationService: locationService,
                    phone: phone,
                    password: password,
                    ipAddresses: ipAddresses,
                    currentIpIndex: initialIpIndex
                )
            }

        container.register(MainContract.Presenter.self, factory: mainPresenterFactory)

        let mainViewFactory: (Resolver, String, String, [String], Int) -> MainContract.View = {
            resolver, phone, password, ipAddresses, initialIpIndex in
                let presenter = resolver.resolve(
                    MainContract.Presenter.self,
                    arguments: phone, password, ipAddresses, initialIpIndex
                )!

                return MainViewController(with: presenter)
            }

        container.register(MainContract.View.self, factory: mainViewFactory)

        return container
    }()

}
