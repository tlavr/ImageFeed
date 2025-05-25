//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Timur Lavrukhin on 24.5.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    // MARK: -Private properties
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: -Public methods
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
