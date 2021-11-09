import UIKit

extension UIAlertController {
    static func simpleAlert(title: String, message msg: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: .none))

        return alert
    }

    static func alert(title: String, message: String, success: ((UIAlertAction) -> Void)? = nil, failure: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: success))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: failure))

        return alert
    }
}
