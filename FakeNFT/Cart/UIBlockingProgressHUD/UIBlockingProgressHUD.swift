import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
  // MARK: - Private Properties:
  private static var window: UIWindow? {
    return UIApplication.shared.windows.first
  }
  
  // MARK: - Methods:
  static func show() {
    window?.isUserInteractionEnabled = false
    ProgressHUD.animate()
    ProgressHUD.animationType = .activityIndicator
    ProgressHUD.colorAnimation = Asset.CustomColors.ypBlack.color
    ProgressHUD.colorStatus = Asset.CustomColors.ypBlack.color
    ProgressHUD.mediaSize = 30
    ProgressHUD.marginSize = 30
  }
  
  static func hide() {
    window?.isUserInteractionEnabled = true
    ProgressHUD.dismiss()
  }
}
