//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit

final class SingleImageViewController : UIViewController {
    // MARK: - Public properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - View state handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    // MARK: - IBActions

}
