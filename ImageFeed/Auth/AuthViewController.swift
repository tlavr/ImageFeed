//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 27.4.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Public properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Public methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                ErrorLoggingService.shared.log(from: String(describing: self), with: .SeguePreparation, error: CommonErrors.seguePreparation(showWebViewSegueIdentifier))
                return
            }
            viewController.authDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "AuthBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "AuthBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.tokenStorage.store(token: token)
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                ErrorLoggingService.shared.log(from: String(describing: self), with: .Network, error: error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: false)
        delegate?.showAlert(self)
    }
}
