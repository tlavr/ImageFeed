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
    private var authViewController: AuthViewController?
    private lazy var splashImageView: UIImageView = {
        let profileImage = UIImage(named: "SplashScreenImage")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupConstraints()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        authViewController?.delegate = self
        authViewController?.modalPresentationStyle = .fullScreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        if tokenStorage.token != nil {
            requestProfile()
        }
        else {
            guard let authViewController else {
                ErrorLoggingService.shared.log(from: String(describing: self), with: .ControllerPresentation, error: CommonErrors.controllerPresentation("AuthViewController"))
                return
            }
            present(authViewController, animated: true)
        }
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashImageView.widthAnchor.constraint(equalToConstant: 75),
            splashImageView.heightAnchor.constraint(equalToConstant: 77),
            splashImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func addSubviews() {
        [splashImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            ErrorLoggingService.shared.log(from: String(describing: self), with: .Window, error: CommonErrors.windowConfiguration)
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
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
                self.profileStorage.store(profile: profileData)
                ProfileImageService.shared.fetchProfileImageURL(username: profileData.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                ErrorLoggingService.shared.log(from: String(describing: self), with: .Network, error: error)
                self.authViewController?.showErrorAlert()
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController) {
        requestProfile()
    }
}
