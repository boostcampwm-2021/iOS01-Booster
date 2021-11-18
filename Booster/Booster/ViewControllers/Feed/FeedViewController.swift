import UIKit

final class FeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum Segue {
        static let feedDetailSegue = "feedDetailSegue"
    }

    // MARK: - Properties
    @IBOutlet private weak var collectionView: UICollectionView!

    var viewModel: FeedViewModel = FeedViewModel()
    private lazy var refershControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let text = "새로고침"
        refreshControl.tintColor = .boosterLabel
        refreshControl.attributedTitle = .makeAttributedString(text: text,
                                                               font: .notoSansKR(.regular, 16),
                                                               color: .label)
        refreshControl.addTarget(self,
                                 action: #selector(refreshPull),
                                 for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        viewModel.fetch()
    }

    // MARK: - @objc
    @objc func refreshPull() {
        viewModel.reset()
    }

    // MARK: - Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailFeedViewController = segue.destination as? DetailFeedViewController
        else { return }
        detailFeedViewController.delegate = self
    }

    func configure() {
        viewModel.trackingRecords.bind {  _ in

            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }

                self.refershControl.endRefreshing()
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadData()
                }
            }
        }

        collectionView.refreshControl = refershControl

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - collection view data source delegate
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recordCount() == 0 ? 1 : viewModel.recordCount()
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        let defaultCellHeight: CGFloat = 175
        let height: CGFloat = viewModel.recordCount() == 0 ? collectionView.frame.height : defaultCellHeight
        let width = collectionView.frame.width-60

        return CGSize(width: width, height: height)
    }
}

// MARK: - scroll view delegate
extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if contentY > contentHeight - scrollView.frame.height {
            viewModel.fetch()
        }
    }
}

// MARK: - detail feed model delegate
extension FeedViewController: DetailFeedModelDelegate {
    func detailFeed(viewModel: DetailFeedViewModel) {
        viewModel.fetchDetailFeedList(start: self.viewModel.selected())
    }
}
