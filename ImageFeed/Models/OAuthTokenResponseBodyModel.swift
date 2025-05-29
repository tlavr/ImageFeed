//
//  OAuthTokenResponseBodyModel.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let tokenScope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case tokenScope = "scope"
        case createdAt = "created_at"
    }
}
