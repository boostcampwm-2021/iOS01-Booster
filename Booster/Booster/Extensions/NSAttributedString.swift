import UIKit

extension NSAttributedString {
    static func make(text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color
        ])
    }
}
