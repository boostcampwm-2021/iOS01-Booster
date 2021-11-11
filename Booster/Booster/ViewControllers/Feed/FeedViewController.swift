import UIKit

final class FeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: FeedViewModel = FeedViewModel()

    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetch()
    }

    func configure() {
        viewModel.trackingRecords.bind { [weak self] _ in
            guard let self = self
            else { return }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - collection view data source delegate
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recordCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel[indexPath]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: item).reuseId, for: indexPath)

        item.configure(cell: cell)
        return cell
    }

}

// MARK: -
extension FeedViewController: UICollectionViewDelegate {
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 175
        let width = collectionView.frame.width-60

        return CGSize(width: width, height: height)
    }
}
