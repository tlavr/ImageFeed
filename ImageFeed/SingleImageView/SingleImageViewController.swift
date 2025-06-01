//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 5.4.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController : UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var shareButton: UIButton!
    
    // MARK: - Public properties
    var imageURL: URL?
    
    // MARK: -Private properies
    private var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            if let size = image?.size { imageView.frame.size = size }
            if let image { rescaleAndCenterImageInScrollView(image: image) }
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.setTitle("", for: .normal)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL,
                              placeholder: UIImage(named: "ImageStub"),
                              options: []) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let value):
                image = value.image
            case .failure(let error):
                image = UIImage(named: "ImageStub")
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .Network,
                    error: error
                )
                self.showErrorAlert()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let images = [image]
        let activityVC = UIActivityViewController(activityItems: images, applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Private methods
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default) { [weak alert] _ in
            guard let alert else { return }
            alert.dismiss(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        } else {
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        scrollView.layoutIfNeeded()
        scrollView.setZoomScale(scale, animated: true)
    }
}

// MARK: -Extensions
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with: UIView?, atScale: CGFloat){
        let newContentSize = scrollView.contentSize
        let visibleRectSize = scrollView.bounds.size
        let insetTopBottom = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        let insetLeftRight = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        scrollView.contentInset = UIEdgeInsets(top: insetTopBottom, left: insetLeftRight,
                                               bottom: insetTopBottom, right: insetLeftRight)
    }
}
