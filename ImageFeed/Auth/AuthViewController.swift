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
    }
    
    // MARK: - Public methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .SeguePreparation,
                    error: CommonErrors.seguePreparation(showWebViewSegueIdentifier)
                )
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewPresenter.view = viewController
            viewController.presenter = webViewPresenter
            viewController.modalPresentationStyle = .overFullScreen
            viewController.authDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func showErrorAlert() {
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
            self.present(alert, animated: true, completion: nil)
        } else {
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.tokenStorage.store(token: token)
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .Network,
                    error: error
                )
            }
        }
    }
    
    func showErrorAlert(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
        sleep(1)
        self.showErrorAlert()
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
