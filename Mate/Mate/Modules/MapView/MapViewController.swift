//
//  MapViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import SwiftUI
import UIKit
import FiableRedux
import CoreLocation

final class MapViewController: UIHostingController<MapView> {
    private let viewModel: MapViewModel

    init(navigationController: UINavigationController?) {
        self.viewModel = MapViewModel(
            navigationController: navigationController
        )
        super.init(rootView: MapView(viewModel: viewModel))

        configureTabBarItem()
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .clear
//        viewModel.viewDidAppear()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We want to hide navigation bar *only* on MapView screen. But on iOS 16, the `navigationBarHidden(true)`
        // modifier on `MapView` view hides the navigation bar for the whole navigation stack.
        // Here we manually hide or show navigation bar when entering or leaving the HubMenu screen.
        if #available(iOS 16.0, *) {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if #available(iOS 16.0, *) {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}

private extension MapViewController {
    func configureTabBarItem() {
        tabBarItem.title = Localization.tabTitle
        tabBarItem.image = .location
        tabBarItem.accessibilityIdentifier = "tab-bar-menu-item"
    }
}

private extension MapViewController {
    enum Localization {
        static let tabTitle = "Dashboard"//NSLocalizedString("Map", comment: "Title of the Menu tab")
    }
}
