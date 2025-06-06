//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Private properties
    private let tokenStorage = OAuth2TokenStorage()
    private let profileStorage = ProfileStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImage(named: "ProfileImagePlaceholder")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    private lazy var logoutButton: UIButton? = {
        let buttonImage = UIImage(named: "LogOutButton")
        guard let buttonImage else { return nil }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didTapLogoutButton))
        button.tintColor = .ypRed
        return button
    } ()
    private lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        if let loginname = profileStorage.loginname {
            usernameLabel.text = loginname
        } else {
            usernameLabel.text = ""
        }
        usernameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        usernameLabel.textColor = .ypWhite
        return usernameLabel
    } ()
    private lazy var accountNameLabel: UILabel = {
        let accountLabel = UILabel()
        if let name = profileStorage.name {
            accountLabel.text = name
        } else {
            accountLabel.text = ""
        }
        accountLabel.font = .systemFont(ofSize: 13, weight: .regular)
        accountLabel.textColor = .ypGray
        return accountLabel
    } ()
    private lazy var customTextLabel: UILabel = {
        let textLabel = UILabel()
        if let bio = profileStorage.bio {
            textLabel.text = bio
        } else {
            textLabel.text = ""
        }
        textLabel.font = .systemFont(ofSize: 13, weight: .regular)
        textLabel.textColor = .ypWhite
        return textLabel
    } ()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubviews()
        setupConstraints()
        if let userProfile = profileStorage.getProfile() {
            usernameLabel.text = userProfile.name
            accountNameLabel.text = userProfile.loginname
            customTextLabel.text = userProfile.bio
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            usernameLabel.heightAnchor.constraint(equalToConstant: 18),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            accountNameLabel.heightAnchor.constraint(equalToConstant: 18),
            accountNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            accountNameLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            customTextLabel.heightAnchor.constraint(equalToConstant: 18),
            customTextLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            customTextLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 8)
        ])
        if let logoutButton = logoutButton {
            NSLayoutConstraint.activate([
                logoutButton.widthAnchor.constraint(equalToConstant: 44),
                logoutButton.heightAnchor.constraint(equalToConstant: 44),
                logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14),
                logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            ])
        }
    }
    
    private func addSubviews() {
        guard let logoutButton = logoutButton else { return }
        [profileImageView, logoutButton, usernameLabel, accountNameLabel, customTextLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profileImageView.kf.setImage(with: imageUrl,
                                     placeholder: UIImage(named: "ProfileImagePlaceholder"),
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
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { [weak alert] _ in
            guard let alert else { return }
            alert.dismiss(animated: true)
        }
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak alert, weak self] _ in
            guard let alert else { return }
            guard let self else { return }
            ProfileLogoutService.shared.logout()
            self.view.window?.rootViewController = SplashViewController()
            alert.dismiss(animated: true)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        } else {
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc
    private func didTapLogoutButton(_ sender: Any) {
        showLogoutAlert()
    }
}
