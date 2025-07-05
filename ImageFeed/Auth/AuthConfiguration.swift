//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation

enum Constants{
    static let accessKey: String = "DMiek_YQ34bPoUHAxJgeMfOh2zQLnXAVqvSBd0TKi8Q"
    static let secretKey: String = "c08YnXbepxLnRwMRDF2j2KI1gpV55LK16D9FOxgva0Q"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: WebViewConstants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
    
    static var testing: AuthConfiguration {
        return AuthConfiguration(accessKey: "bHBk1N8R9yjpEsfVmIs1BtRCnh6fRrn6ogGBhbPfCGk",
                                 secretKey: "gaJ3JRfL3VktnwmTnaOvA2Ljd-bllrCYborMQ7Hlr0w",
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: WebViewConstants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}

