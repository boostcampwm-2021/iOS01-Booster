import UIKit

extension UIAlertController {
    static func simpleAlert(title: String, message msg: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))

        return alert
    }
}
