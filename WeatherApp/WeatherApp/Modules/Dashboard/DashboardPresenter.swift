//
//  DashboardPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking

/// Protocol defining the interactions handled by the DashboardPresenter.
protocol DashboardPresenterProtocol: AnyObject {
    /// Called when the view is loaded and ready.
    func viewDidLoad()
    /// Presents weather information.
    ///
    /// - Parameter weatherInfo: The weather information to present.
    func presentWeatherInfo(_ weatherInfo: WeatherResponse)
}

/// Class responsible for presenting data to the dashboard view.
final class DashboardPresenter: DashboardPresenterProtocol {
    /// Reference to the dashboard view.
    unowned var view: DashboardViewControllerProtocol?
    /// Reference to the router handling navigation.
    let router: DashboardRouterProtocol?
    /// Reference to the interactor handling data retrieval.
    let interactor: DashboardInteractorProtocol?
    
    /// Initializes the presenter with required dependencies.
    ///
    /// - Parameters:
    ///   - view: The dashboard view.
    ///   - router: The router for navigation.
    ///   - interactor: The interactor for data retrieval.
    init(
        view: DashboardViewControllerProtocol,
        router: DashboardRouterProtocol,
        interactor: DashboardInteractorProtocol
    ){
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    /// Called when the view is loaded and ready.
    func viewDidLoad() {
        interactor?.fetchWeatherForUserLocation()
    }
}

// Extension for additional protocol conformance
extension DashboardPresenter: DashboardInteractorOutputProtocol {
    func fetchWeatherOutput(result: Networking.WeatherResponse) {
        view?.displayWeatherInfo(result)
    }
    
    /// Outputs the result of weather data retrieval.
    ///
    /// - Parameter result: The retrieved weather data.
    func fetchWeatherOutput(result: Networking.CurrentWeather) {
        DDLogInfo(#function)
    }
    
    func presentWeatherInfo(_ weatherInfo: WeatherResponse) {
        view?.displayWeatherInfo(weatherInfo)
    }
}
