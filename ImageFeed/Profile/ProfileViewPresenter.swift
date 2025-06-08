//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import Foundation
import Kingfisher

final class ProfileViewPresenter: @preconcurrency ProfileViewPresenterProtocol {
    // MARK: -Public properties
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: -Private properies
    private let tokenStorage = OAuth2TokenStorage()
    private let profileStorage = ProfileStorage()
    
    // MARK: -Public methods
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func getLogin() -> String {
        if let loginname = profileStorage.loginname {
            return loginname
        } else {
            return ""
        }
    }
    
    func getName() -> String {
        if let name = profileStorage.name {
            return name
        } else {
            return ""
        }
    }
    
    func getBio() -> String {
        if let bio = profileStorage.bio {
            return bio
        } else {
            return ""
        }
    }
    
    func performLogout() {
        ProfileLogoutService.shared.logout()
    }
    
    @MainActor func setAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        view?.profileImageView.kf.setImage(with: imageUrl,
                                           placeholder: view?.placeholderImage,
                                           options: [.processor(processor),
                                                     .cacheSerializer(FormatIndicatedCacheSerializer.png)]) { result in
                                                         switch result {
                                                         case .success(_):
                                                             break
                                                         case .failure(let error):
                                                             ErrorLoggingService.shared.log(
                                                                from: String(describing: self),
                                                                with: .Network,
                                                                error: error
                                                             )
                                                         }
                                                     }
    }
}
