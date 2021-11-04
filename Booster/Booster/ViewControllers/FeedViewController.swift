import UIKit

final class FeedViewController: UIViewController {

    // MARK: Properties

    @IBOutlet private weak var tableView: UITableView!

    private let feedViewModel = FeedViewModel()
    private lazy var emptyView = EmptyView()

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureEmptyUI()
        bindFeedViewModel()
        tableView.dataSource = self
    }

    private func configureEmptyUI() {
        emptyView = EmptyView.init(frame: self.tableView.frame)
        emptyView.apply(title: "아직 산책기록이 없어요\n오늘 한 번 천천히 걸어볼까요?", image: UIImage(named: "foot") ?? UIImage())
        self.view.addSubview(emptyView)
    }

    private func bindFeedViewModel() {
        feedViewModel.trackingRecords.bind { [weak self] _ in
             if self?.feedViewModel.recordCount() == 0 { return }
            DispatchQueue.main.async {
                self?.emptyView.removeFromSuperview()
                self?.tableView.reloadData()
            }
        }
    }

}

// MARK: - TableView DataSource

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.recordCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as? FeedTableViewCell,
              let data = feedViewModel.dataAtIndex(indexPath.row)
        else { return UITableViewCell() }

        cell.configure(with: data)

        return cell
    }

}
