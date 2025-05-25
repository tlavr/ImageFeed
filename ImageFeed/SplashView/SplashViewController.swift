//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Public properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthView"
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileStorage = ProfileStorage()
    
    // MARK: - View lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        if tokenStorage.token != nil {
            requestProfile()
        }
        else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            ErrorLoggingService.shared.log(from: String(describing: self), with: .Window, error: CommonErrors.windowConfiguration)
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func showErrorAlert(_ vc: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default) { [weak alert] _ in
            guard let alert else { return }
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        if self.presentedViewController == nil {
            self.performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        self.presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func requestProfile() {
        guard
            let token = tokenStorage.token
        else {
            ErrorLoggingService.shared.log(from: String(describing: self), with: .Database, error: CommonErrors.tokenStorage)
            return
        }
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let profileData):
                self.navigationController?.popViewController(animated: true)
                print("Profile data has been successfully loaded: \(profileData)")
                self.profileStorage.store(profile: profileData)
                ProfileImageService.shared.fetchProfileImageURL(username: profileData.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                ErrorLoggingService.shared.log(from: String(describing: self), with: .Network, error: error)
                self.showErrorAlert(self)
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController) {
        requestProfile()
    }
    func showAlert(_ vc: AuthViewController) {
        showErrorAlert(vc)
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                ErrorLoggingService.shared.log(from: String(describing: self), with: .SeguePreparation, error: CommonErrors.seguePreparation(showAuthenticationScreenSegueIdentifier))
                return
            }
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
