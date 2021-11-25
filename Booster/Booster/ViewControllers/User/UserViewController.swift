import UIKit

final class UserViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum sectionType: Int, CaseIterable {
        case userHeader = 0
        case myInfo
    }

    private enum MyInfoCellType: Int {
        case removeAllData = 0
        case changeGoal
        case editUserInfo
        case notificationSetting

        var title: String {
            switch self {
            case .removeAllData:
                return "모든 데이터 지우기"
            case .changeGoal:
                return "목표 바꾸기"
            case .editUserInfo:
                return "개인 정보 수정"
            case .notificationSetting:
                return "알람 설정"
            }
        }
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var userTableView: UITableView!

    // MARK: - Properties
    var viewModel: UserViewModel = UserViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        userTableView.dataSource = self
        userTableView.delegate = self
        registerNib()
        configureNavigationBarTitle()
        navigationController?.interactivePopGestureRecognizer?.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        userTableView.reloadData()
        navigationController?.navigationBar.isHidden = true
        navigationItem.title = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Functions
    private func registerNib() {
        userTableView.register(UINib(nibName: UserInfoHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: UserInfoHeaderView.identifier)
        userTableView.register(UINib(nibName: MyInfoHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: MyInfoHeaderView.identifier)
        userTableView.register(UINib(nibName: UserInfoBaseCell.identifier, bundle: nil), forCellReuseIdentifier: UserInfoBaseCell.identifier)
    }

    private func configureNavigationBarTitle() {
        let attribute = [NSAttributedString.Key.font: UIFont.notoSansKR(.light, 18)]

        navigationController?.navigationBar.titleTextAttributes = attribute
    }

    private func myInfoCellDidSelectActions(cellType: MyInfoCellType) {
        switch cellType {
        case .removeAllData:
            guard let removeAllDataViewController = storyboard?.instantiateViewController(identifier: RemoveAllDataViewController.identifier, creator: { [weak self] coder -> RemoveAllDataViewController in
                guard let viewModel = self?.viewModel
                else { return RemoveAllDataViewController(viewModel: UserViewModel()) }

                return .init(coder: coder, viewModel: viewModel) ?? RemoveAllDataViewController(viewModel: UserViewModel())
            })
            else { return }

            navigationController?.pushViewController(removeAllDataViewController, animated: true)
        case .changeGoal:
            guard let changeGoalViewController = storyboard?.instantiateViewController(identifier: ChangeGoalViewController.identifier, creator: { [weak self] coder -> ChangeGoalViewController in
                guard let viewModel = self?.viewModel
                else { return ChangeGoalViewController(viewModel: UserViewModel()) }

                return .init(coder: coder, viewModel: viewModel) ?? ChangeGoalViewController(viewModel: UserViewModel())
            })
            else { return }

            navigationController?.pushViewController(changeGoalViewController, animated: true)
        case .editUserInfo:
            guard let editUserInfoViewController = storyboard?.instantiateViewController(identifier: EditUserInfoViewController.identifier, creator: { [weak self] coder -> EditUserInfoViewController in
                guard let viewModel = self?.viewModel
                else { return EditUserInfoViewController(viewModel: UserViewModel()) }

                return .init(coder: coder, viewModel: viewModel) ?? EditUserInfoViewController(viewModel: UserViewModel())
            })
            else { return }

            navigationController?.pushViewController(editUserInfoViewController, animated: true)
        case .notificationSetting:
            guard let notificationSettingViewController = storyboard?.instantiateViewController(withIdentifier: NotificationSettingViewController.identifier) as? NotificationSettingViewController
            else { return }

            navigationController?.pushViewController(notificationSettingViewController, animated: true)
        }
    }
}

// MARK: - TableViewDataSource
extension UserViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionType.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = sectionType(rawValue: section)
        else { return 0 }

        switch sectionType {
        case .userHeader: return 0
        case .myInfo: return 4
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = sectionType(rawValue: section)
        else { return UIView() }

        var header: UITableViewHeaderFooterView?

        switch sectionType {
        case .userHeader:
            guard let headerView = userTableView.dequeueReusableHeaderFooterView(withIdentifier: UserInfoHeaderView.identifier) as? UserInfoHeaderView
            else { return nil }

            headerView.configure(viewModel: viewModel)

            header = headerView
        case .myInfo:
            guard let headerView = userTableView.dequeueReusableHeaderFooterView(withIdentifier: MyInfoHeaderView.identifier) as? MyInfoHeaderView
            else { return nil }

            header = headerView
        }

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionTitle = sectionType(rawValue: indexPath.section)
        else { return UITableViewCell() }

        var cell: UITableViewCell?

        switch sectionTitle {
        case .userHeader:
            return UITableViewCell()
        case .myInfo:
            guard let customCell = userTableView.dequeueReusableCell(withIdentifier: UserInfoBaseCell.identifier) as? UserInfoBaseCell,
                  let cellType = MyInfoCellType(rawValue: indexPath.row)
            else { return UITableViewCell() }

            customCell.configure(title: cellType.title)

            cell = customCell
        }

        cell?.selectionStyle = .none
        guard let cell = cell
        else { return UITableViewCell() }

        return cell
    }
}

// MARK: - TableViewDelegate
extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = sectionType(rawValue: section)
        else { return 0 }

        switch sectionType {
        case .userHeader:
            return UserInfoHeaderView.viewHeight
        case .myInfo:
            return MyInfoHeaderView.viewHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight: CGFloat = UserInfoBaseCell.cellHeight

        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = sectionType(rawValue: indexPath.section)
        else { return }

        switch sectionType {
        case .userHeader:
            break
        case .myInfo:
            guard let cellType = MyInfoCellType(rawValue: indexPath.row)
            else { return }

            myInfoCellDidSelectActions(cellType: cellType)
        }
    }

}

// MARK: - navigationController.interactivePopGestureRecognizer.delegate
extension UserViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
