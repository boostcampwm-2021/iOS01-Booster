import UIKit

final class FeedViewController: UIViewController, BaseViewControllerTemplate {
    enum Segue {
        static let feedDetailSegue = "feedDetailSegue"
    }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailFeedViewController = segue.destination as? DetailFeedViewController
        else { return }
        detailFeedViewController.delegate = self
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

// MARK: - collection view delegate
extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selected(indexPath)
        performSegue(withIdentifier: Segue.feedDetailSegue, sender: nil)
    }
}

// MARK: - collection view flow layout delegate
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 175
        let width = collectionView.frame.width-60

        return CGSize(width: width, height: height)
    }
}

extension FeedViewController: DetailFeedModelDelegate {
    func detailFeed(viewModel: DetailFeedViewModel) {
        viewModel.configure(model: self.viewModel.selected())
    }
}
