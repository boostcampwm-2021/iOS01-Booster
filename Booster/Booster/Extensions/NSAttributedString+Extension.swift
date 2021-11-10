import UIKit

extension NSAttributedString {
    static func makeAttributedString(text: String,
                                     font: UIFont,
                                     color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
    }
}
