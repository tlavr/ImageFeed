//
//  ProfileDataResponseBodyModel.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

struct ProfileDataResponseBody: Decodable {
    let userID: String
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    let totalPhotos: Int?
    
    private enum CodingKeys: String, CodingKey {
        case userID = "id"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
        case totalPhotos = "total_photos"
    }
}
