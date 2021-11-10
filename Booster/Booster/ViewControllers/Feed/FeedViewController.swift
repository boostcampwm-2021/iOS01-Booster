import UIKit

final class FeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel = FeedViewModel()
    private lazy var emptyView: EmptyView = {
        let view = EmptyView.init(frame: tableView.frame)
        let emptyViewTitle = "아직 산책기록이 없어요\n오늘 한 번 천천히 걸어볼까요?"
        
        view.apply(title: emptyViewTitle, image: UIImage.assetFoot)
        return view
    }()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    func configure() {
        bindFeedViewModel()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindFeedViewModel() {
        viewModel.trackingRecords.bind { [weak self] _ in
            guard let self = self
            else { return }
            
            if self.viewModel.recordCount() == 0 {
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
        return viewModel.recordCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as? FeedTableViewCell,
              let data = viewModel.dataAtIndex(indexPath.row)
        else { return UITableViewCell() }

        cell.configure(with: data)

        return cell
    }
}

// MARK: - TableView Delegate
extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: DetailFeedViewController.identifier) as? DetailFeedViewController
        else { return }
        nextViewController.trackingInfo = viewModel.dataAtIndex(indexPath.row)

        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
