//
//  Constants.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 21.4.2025.
//

import Foundation

enum Constants{
    static let accessKey: String = "DMiek_YQ34bPoUHAxJgeMfOh2zQLnXAVqvSBd0TKi8Q"
    static let secretKey: String = "c08YnXbepxLnRwMRDF2j2KI1gpV55LK16D9FOxgva0Q"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
}

enum AuthConstants {
    static let tokenRequestURLString = "https://unsplash.com/oauth/token"
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
