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
    private let profileStorage = ProfileStorage()
    private enum JsonError: Error {
        case decoderError
    }
    
    // MARK: - View lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        if tokenStorage.token != nil {
            requestProfile()
            switchToTabBarController()
        }
        else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func generateProfileRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Generate profile request URLComponent initialization failed")
            return nil
        }
        urlComponents.path = "/me"
        guard let url = urlComponents.url else {
            assertionFailure("Generate token request URL initialization failed")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = tokenStorage.token else {
            assertionFailure("Token reading from Storage failed")
            return nil
        }
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func fetchProfileData(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let URLRequest = generateProfileRequest() else { return }
        
        let task = URLSession.shared.data(for: URLRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let profileData = try JSONDecoder().decode(ProfileDataResponseBody.self, from: data)
                    let profile = ProfileModel(
                        userID: profileData.userID,
                        username: profileData.username,
                        firstName: profileData.firstName,
                        lastName: profileData.lastName,
                        totalPhotos: profileData.totalPhotos
                    )
                    completion(.success(profile))
                } catch {
                    completion(.failure(JsonError.decoderError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func requestProfile() {
        fetchProfileData() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileData):
                    print("Profile data has been loaded successfully: \(profileData)")
                case .failure(let error):
                    assertionFailure("Error occured during profile data loading: \(error)")
                }
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController) {
        navigationController?.popViewController(animated: true)
        requestProfile()
        switchToTabBarController()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
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

struct ProfileDataResponseBody: Decodable {
    let userID: String
    let username: String
    let firstName: String
    let lastName: String
    let totalPhotos: Int
    
    private enum CodingKeys: String, CodingKey {
        case userID = "id"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case totalPhotos = "total_photos"
    }
}
