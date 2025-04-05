//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Public properties
    
    // MARK: - IBOutlets
    @IBOutlet private var customTextLabel: UILabel!
    @IBOutlet private var accountNameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    @IBOutlet private var profileImage: UIImageView!
    
    // MARK: - View state handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.setTitle("", for: .normal)
    }
    // MARK: - IBActions
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
}
