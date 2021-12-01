import UIKit

extension UIFont {
    enum NotoSans: String {
        case thin = "Thin", light = "Light", regular = "Regular", medium = "Medium", bold = "Bold", black = "Black"
    }

    static func bazaronite(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Bazaronite", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }

        return font
    }

    static func notoSansKR(_ font: NotoSans, _ size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "NotoSansKR-\(font.rawValue)", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }

        return font
    }
}
