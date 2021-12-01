import UIKit
import RxSwift

final class FeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - IBOutlet
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var viewModel = FeedViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetch()
    }

    // MARK: - Functions
    private func bind() {
        viewModel.list.bind { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }

                self.collectionView.reloadData()
            }
        }.disposed(by: disposeBag)

        viewModel.next
            .bind { [weak self] date in
                let storyboardName = "Feed"
                let detailFeedViewController = UIStoryboard(name: storyboardName, bundle: .main)
                    .instantiateViewController(identifier: DetailFeedViewController.identifier) { coder in
                        return DetailFeedViewController(coder: coder, viewModel: DetailFeedViewModel(start: date))
                    }

                self?.navigationController?.pushViewController(detailFeedViewController, animated: true)

            }.disposed(by: disposeBag)
    }

    func configure() {
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
        viewModel.select.on(.next(indexPath))
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
