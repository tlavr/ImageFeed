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
            if let size = image?.size { imageView.frame.size = size }
            if let image { rescaleAndCenterImageInScrollView(image: image) }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var shareButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.setTitle("", for: .normal)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.image = image
        if let size = image?.size { imageView.frame.size = size }
        if let image { rescaleAndCenterImageInScrollView(image: image) }
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
