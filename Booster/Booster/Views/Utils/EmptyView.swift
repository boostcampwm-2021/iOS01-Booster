import UIKit

final class EmptyView: UIView {
    // MARK: - Properties
    private let imageView = UIImageView()
    private let titlelabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }

    // MARK: - Functions
    private func configureLayout() {
        addSubview(imageView)
        addSubview(titlelabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: self.frame.width / 5).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: self.frame.width / 5 * 52 / 70).isActive = true
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        titlelabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titlelabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40).isActive = true
    }

    func apply(title: String, image: UIImage) {
        imageView.image = image
        titlelabel.text = title
        titlelabel.textColor = .boosterGray
        titlelabel.numberOfLines = 2
        titlelabel.textAlignment = .center
        titlelabel.font = .notoSansKR(.regular, 17)
    }
}
