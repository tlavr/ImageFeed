//
//  ViewController.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 29.3.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private properties
    private let imagesList = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(named: "YP Black (iOS)")
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        }
        requestPhotos()
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                if let newPhotos = notification.userInfo?["Photos"] as? [Photo] {
                    self.photos = newPhotos
                    self.updateTableViewAnimated()
                }
            }
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
            viewController.imageInfo = photos[indexPath.row]
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let thumbImageStr = photos[indexPath.row].thumbImageURL
        guard let thumbImageUrl = URL(string: thumbImageStr) else {
            ErrorLoggingService.shared.log(
                from: String(describing: self),
                with: .UrlSession,
                error: CommonErrors.url
            )
            return
        }
        
        cell.delegate = self
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: thumbImageUrl,
                                   placeholder: UIImage(named: "ImageStub"),
                                   options: []) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                cell.cellImage.image = value.image
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .Network,
                    error: error
                )
            }
        }
        let imageDate = photos[indexPath.row].createdAt ?? Date()
        cell.dateLabel.text = dateFormatter.string(from: imageDate)
        cell.likeButton.setTitle("", for: .normal)
        if photos[indexPath.row].isLiked {
            cell.likeButton.setImage(UIImage(named: "LikeActive"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "LikeNotActive"), for: .normal)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldPhotosCount = photos.count - ImagesListConstants.photosPerPage
        let newPhotosCount = photos.count
        var indexPaths: [IndexPath] = []
        (oldPhotosCount..<newPhotosCount).forEach {
            indexPaths.append(IndexPath(row: $0, section: 0))
        }
        tableView.performBatchUpdates {
            self.tableView.insertRows(
                at: indexPaths,
                with: .automatic
            )
        } completion: { _ in }
    }
    
    private func requestPhotos() {
        imagesList.fetchPhotosNextPage() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                break
            case .failure(let error):
                ErrorLoggingService.shared.log(
                    from: String(describing: self),
                    with: .UrlSession,
                    error: error
                )
            }
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    private func showErrorAlert() {
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
}

// MARK: -Extensions
extension ImagesListViewController : UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { photos.count }
    
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
        if photos.isEmpty { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            requestPhotos()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesList.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                    self.photos[index].isLiked = !self.photos[index].isLiked
                }
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showErrorAlert()
            }
        }
    }
}
