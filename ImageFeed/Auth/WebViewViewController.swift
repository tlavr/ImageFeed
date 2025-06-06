//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 27.4.2025.
//

import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: -Private properties
    private var estimatedProgressObservation: NSKeyValueObservation?
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AuthBackButton"), for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        return button
    } ()
    
    // MARK: - Public properties
    weak var authDelegate: WebViewViewControllerDelegate?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        loadAuthView()
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 self.updateProgress()
             })
    }
    
    // MARK: - IBActions
    @objc
    private func didTapBackButton(_ sender: Any?) {
        authDelegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private methods
    private func configureBackButton() {
        [backButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9)
        ])
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.urlComponent
            )
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            authDelegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if(error.localizedDescription == "The Internet connection appears to be offline.")
        {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .Network,
                error: error
            )
            authDelegate?.showErrorAlert(self)
        }
    }
}
