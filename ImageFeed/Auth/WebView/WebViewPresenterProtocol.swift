//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var view: WebViewViewControllerProtocol? { get set }
}
