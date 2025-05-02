//
//  WebViewViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 1.5.2025.
//

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
