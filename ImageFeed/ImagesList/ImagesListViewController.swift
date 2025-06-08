//
//  ViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.3.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    // MARK: -Public properties
    var presenter: ImagesListViewPresenterProtocol?
    lazy var imageStub: UIImage? = UIImage(named: "ImageStub")
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(named: "YP Black (iOS)")
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        }
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.addPhotos()
            }
        presenter?.requestPhotos()
    }
    
    // MARK: - Public methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .SeguePreparation,
                    error: CommonErrors.segueDestination
                )
                return
            }
            viewController.imageInfo = presenter?.getPhoto(with: indexPath.row)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func reloadTableRows(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func setCellDate(for cell: ImagesListCell, with text: String) {
        cell.dateLabel.text = text
    }
    
    func setCellLikeActive(for cell: ImagesListCell) {
        cell.likeButton.setTitle("", for: .normal)
        cell.likeButton.setImage(UIImage(named: "LikeActive"), for: .normal)
    }
    
    func setCellLikeInactive(for cell: ImagesListCell) {
        cell.likeButton.setTitle("", for: .normal)
        cell.likeButton.setImage(UIImage(named: "LikeNotActive"), for: .normal)
    }
    
    func setCellImage(for cell: ImagesListCell, with image: UIImage) {
        cell.cellImage.image = image
    }
    
    func updateTableRows(for indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            self.tableView.insertRows(
                at: indexPaths,
                with: .automatic
            )
        } completion: { _ in }
    }
    
    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробуйте еще раз",
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
    
    // MARK: - Private methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        presenter?.configureCell(for: cell, with: indexPath)
    }
}

// MARK: -Extensions
extension ImagesListViewController : UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { presenter?.getPhotosCount() ?? 0 }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController : UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let photo = presenter?.getPhoto(with: indexPath.row) else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.checkIfNewPhotosNeeded(for: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.changeLike(for: cell, with: indexPath.row)
    }
}
