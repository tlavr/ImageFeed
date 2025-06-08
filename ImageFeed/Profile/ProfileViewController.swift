//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    // MARK: -Public properties
    var presenter: ProfileViewPresenterProtocol?
    
    lazy var profileImageView: UIImageView = {
        let profileImage = placeholderImage
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    
    lazy var placeholderImage: UIImage? = UIImage(named: "ProfileImagePlaceholder")
    
    // MARK: - Private properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var logoutButton: UIButton? = {
        let buttonImage = UIImage(named: "LogOutButton")
        guard let buttonImage else { return nil }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didTapLogoutButton))
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "LogoutButton"
        return button
    } ()
    
    private(set) lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.text = presenter?.getName()
        usernameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        usernameLabel.textColor = .ypWhite
        return usernameLabel
    } ()
    
    private(set) lazy var accountNameLabel: UILabel = {
        let accountLabel = UILabel()
        accountLabel.text = presenter?.getLogin()
        accountLabel.font = .systemFont(ofSize: 13, weight: .regular)
        accountLabel.textColor = .ypGray
        return accountLabel
    } ()
    private(set) lazy var customTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = presenter?.getBio()
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
        usernameLabel.text = presenter?.getName()
        accountNameLabel.text = presenter?.getLogin()
        customTextLabel.text = presenter?.getBio()
        
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
        presenter?.setAvatar()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "LogoutAlert"
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { [weak alert] _ in
            guard let alert else { return }
            alert.dismiss(animated: true)
        }
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak alert, weak self] _ in
            guard let alert else { return }
            guard let self else { return }
            self.presenter?.performLogout()
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
