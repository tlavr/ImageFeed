//
//  ProfileImageModel.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.5.2025.
//

struct ProfileImageModel: Decodable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}
