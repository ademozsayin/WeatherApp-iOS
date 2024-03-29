//
//  DashboardPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking
import CoreLocation

// MARK: - DashboardPresenterProtocol

/// Protocol defining the interactions handled by the DashboardViewController.
protocol DashboardPresenterProtocol: AnyObject {
    /// Called when the view is loaded and ready.
    func viewDidLoad()
    /// Presents weather information.
    ///
    /// - Parameter weatherInfo: The weather information to present.
    func presentWeatherInfo(_ weatherInfo: WeatherResponse)
    
    /// Displays the last saved user location.
    ///
    /// - Parameter completion: A closure to be executed when the operation completes. It returns the last saved user location, if available.
    func displayLastSavedLocation(completion: @escaping (UserLocation?) -> Void)
    
    /// Notifies the presenter when user location fetching fails.
    ///
    /// - Parameter error: The error encountered during user location fetching.
    func didFailToFetchUserLocation(withError error: Error)
    
    func weatherDay(index: Int) -> List?
    
    var numberOfDays: Int {get}
    
    func didFailedWith(message: String)
    
    func didSearchTapped()
}

// MARK: - DashboardPresenter

/// Class responsible for presenting the dashboard view.
final class DashboardPresenter {
    
    // MARK: - Properties
    
    /// Reference to the dashboard view.
    unowned var view: DashboardViewControllerProtocol?
    /// Reference to the router handling navigation.
    let router: DashboardRouterProtocol?
    /// Reference to the interactor handling data retrieval.
    let interactor: DashboardInteractorProtocol?
    
    private var dailyWeatherList:[List] = []
    
    // MARK: - Initialization
    
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
}

// MARK: - DashboardPresenterProtocol
extension DashboardPresenter: DashboardPresenterProtocol {
    final func didSearchTapped() {
        router?.navigate(.search)
    }
    
    var numberOfDays: Int {
        return dailyWeatherList.count
    }
    
    func weatherDay(index: Int) -> List? {
        guard dailyWeatherList.count > index else {
            return nil
        }
        return dailyWeatherList[index]
    }
    
    /// Displays the last saved location asynchronously.
    ///
    /// - Parameter completion: A closure to be executed when the operation completes. It returns the last saved user location, if available.
    final func displayLastSavedLocation(completion: @escaping (UserLocation?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let lastLocation = self.interactor?.fetchLastSavedLocation() {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    print("Last saved location: \(lastLocation)")
                    self.view?.showLastUpdatedWeather(info: lastLocation)
                    // Call completion handler with the fetched location
                    completion(lastLocation)
                }
            } else {
                // Call completion handler with nil if no location is found
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    /// Called when the view is loaded and ready.
    final func viewDidLoad() {
        view?.showLoading()
        // Display last saved location when view loads
        displayLastSavedLocation { [weak self] location in
            guard let self = self else { return }
            self.interactor?.fetchWeatherForUserLocation()
        }
    }
    
    func presentWeatherInfo(_ weatherInfo: Networking.WeatherResponse) { }
}

// MARK: - DashboardInteractorOutputProtocol
extension DashboardPresenter: DashboardInteractorOutputProtocol {
   
    func fetchDailyOutput(result: [List]) {
        self.dailyWeatherList = result
        view?.reloadData()
    }
    
    final func fetchWeatherOutput(result: WeatherResponse) {
        view?.displayWeatherInfo(result)
        view?.hideLoading()
    }
    
    /// Notifies the presenter when user location fetching fails.
    ///
    /// - Parameter error: The error encountered during user location fetching.
    func didFailToFetchUserLocation(withError error: Error) {
        print(error)
        view?.hideLoading()
        view?.showLocationError(error: error)
    }
    
    final func didFailedWith(message:String) {
        view?.showAlert(message: message)
    }
}
