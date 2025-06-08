//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    var profileImageView: UIImageView { get set }
    var placeholderImage: UIImage? { get }
}
