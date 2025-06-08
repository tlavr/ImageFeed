//
//  AuthHelperProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
