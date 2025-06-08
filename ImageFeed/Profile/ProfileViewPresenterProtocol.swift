//
//  ProfileViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 8.6.2025.
//

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func getLogin() -> String
    func getName() -> String
    func getBio() -> String
    func setAvatar()
    func performLogout()
}
