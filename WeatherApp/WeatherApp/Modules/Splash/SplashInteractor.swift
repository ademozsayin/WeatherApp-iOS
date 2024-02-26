//
//  SplashInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

// MARK: - SplashInteractorProtocol
protocol SplashInteractorProtocol: AnyObject {
    func checkInternetConnection()
}

// MARK: - SplashInteractorOutputProtocol
protocol SplashInteractorOutputProtocol: AnyObject {
    func internetConnection(status: Bool)
}

// MARK: - SplashInteractor
/// Interactor responsible for handling business logic related to the Splash module.
final class SplashInteractor {
    
    /// The output delegate for the interactor.
    var output: SplashInteractorOutputProtocol?
    
    /// Initializes the Splash Interactor.
    ///
    /// - Parameter output: An optional output delegate conforming to `SplashInteractorOutputProtocol`.
    init(output: SplashInteractorOutputProtocol? = nil) {
        self.output = output
    }
}

extension SplashInteractor: SplashInteractorProtocol {
    func checkInternetConnection() {}
}