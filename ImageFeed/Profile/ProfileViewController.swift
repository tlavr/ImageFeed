//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Public properties
    
    // MARK: - Private properties
    private var profileImageView: UIImageView?
    private var logoutButton: UIButton?
    private var usernameLabel: UILabel?
    private var accountNameLabel: UILabel?
    private var customTextLabel: UILabel?
       
    // MARK: - View state handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        setupProfileImageView()
        setupLogoutButton()
        setupLabels()
        setupConstraints()
    }
    
    private func setupConstraints() {
        if let profileImageView = profileImageView,
           let logoutButton = logoutButton,
           let usernameLabel = usernameLabel,
           let accountNameLabel = accountNameLabel,
           let customTextLabel = customTextLabel
        {
            profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
           
            logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14).isActive = true
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
            
            usernameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
            accountNameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            accountNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
            accountNameLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
            customTextLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            customTextLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
            customTextLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 8).isActive = true
        }
    }
    
    private func setupProfileImageView() {
        let profileImage = UIImage(named: "ProfilePicture")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView = imageView
        view.addSubview(imageView)
    }
        
    private func setupLogoutButton() {
        let buttonImage = UIImage(named: "LogOutButton")
        guard let buttonImage = buttonImage else { return }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didTapLogoutButton))
        button.tintColor = UIColor(named: "YP Red (iOS)")
        button.translatesAutoresizingMaskIntoConstraints = false
        logoutButton = button
        view.addSubview(button)
    }
    
    @objc
    private func didTapLogoutButton(_ sender: Any) {
        print("Logout button tapped")
    }
    
    private func setupLabels() {
        let usernameLabel = UILabel()
        usernameLabel.text = "Екатерина Новикова"
        usernameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        usernameLabel.textColor = UIColor(named: "YP White (iOS)")
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.usernameLabel = usernameLabel
        view.addSubview(usernameLabel)
        
        let accountLabel = UILabel()
        accountLabel.text = "@ekaterina_nov"
        accountLabel.font = .systemFont(ofSize: 13, weight: .regular)
        accountLabel.textColor = UIColor(named: "YP Gray (iOS)")
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.accountNameLabel = accountLabel
        view.addSubview(accountLabel)
        
        let textLabel = UILabel()
        textLabel.text = "Hello, world!"
        textLabel.font = .systemFont(ofSize: 13, weight: .regular)
        textLabel.textColor = UIColor(named: "YP White (iOS)")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.customTextLabel = textLabel
        view.addSubview(textLabel)
    }
}
