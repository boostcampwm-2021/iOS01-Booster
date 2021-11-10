import UIKit

final class FeedViewController: UIViewController {

    // MARK: Properties

    @IBOutlet private weak var tableView: UITableView!

    private let feedViewModel = FeedViewModel()
    private lazy var emptyView: EmptyView = {
        let view = EmptyView.init(frame: self.tableView.frame)
        let emptyViewTitle = "아직 산책기록이 없어요\n오늘 한 번 천천히 걸어볼까요?"
        view.apply(title: emptyViewTitle, image: UIImage(assetName: .foot) ?? UIImage())
        return view
    }()

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        bindFeedViewModel()
        tableView.dataSource = self
        tableView.delegate = self
    }

}

// MARK: - Bind & Prepare Segue

extension FeedViewController {

    private func bindFeedViewModel() {
        feedViewModel.trackingRecords.bind { [weak self] _ in
            guard let self = self else { return }
            if self.feedViewModel.recordCount() == 0 {
                self.view.addSubview(self.emptyView)
                return
            }
            DispatchQueue.main.async {
                self.emptyView.removeFromSuperview()
                self.tableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as? FeedTableViewCell,
              let data = feedViewModel.dataAtIndex(indexPath.row)
        else { return UITableViewCell() }

        cell.configure(with: data)

        return cell
    }

}

// MARK: - TableView Delegate

extension FeedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: DetailFeedViewController.identifier) as? DetailFeedViewController else { return }
        nextViewController.trackingInfo = feedViewModel.dataAtIndex(indexPath.row)

        navigationController?.pushViewController(nextViewController, animated: true)
    }

}
