import UIKit

extension UIFont {
    static func bazaronite(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Bazaronite", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }

        return font
    }
}
