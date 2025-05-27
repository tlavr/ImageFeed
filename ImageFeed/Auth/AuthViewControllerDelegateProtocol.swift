//
//  AuthViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 2.5.2025.
//

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
