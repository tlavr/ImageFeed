//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 26.5.2025.
//

import UIKit
 
final class TabBarController: UITabBarController {
    // MARK: -Public methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListVC = imagesListViewController as? ImagesListViewControllerProtocol
        else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .ControllerPresentation,
                error: CommonErrors.controllerPresentation("ImagesListViewController")
            )
            return
        }
        let imagesListViewPresenter = ImagesListViewPresenter(view: imagesListVC)
        imagesListVC.presenter = imagesListViewPresenter
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter(view: profileViewController)
        profileViewController.presenter = profileViewPresenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "ProfileTabActiveImage"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
