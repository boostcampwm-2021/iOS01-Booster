import UIKit

class UserViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum sectionType: Int, CaseIterable {
        case userHeader = 0
        case myInfo
    }

    private enum cellIdentifier: String, CaseIterable {
        case eraseAllData = "eraseAllDataCell"
        case changeGoal = "changeGoalCell"
        case editUserInfo = "editUserInfoCell"
        case notificationSetting = "notificationSettingCell"
    }

    private enum MyInfoCellType: Int {
        case eraseAllData = 0
        case changeGoal
        case editUserInfo
        case notificationSetting

        func title() -> String {
            switch self {
            case .eraseAllData:
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
    @IBOutlet var userTableView: UITableView!

    // MARK: - Properties
    var viewModel: UserViewModel = UserViewModel()
    let userHeaderHeight: CGFloat = 200
    let myInfoHeaderHeight: CGFloat = 60
    let cellHeight: CGFloat = 60

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        userTableView.dataSource = self
        userTableView.delegate = self
        registerNib()
    }

    // MARK: - @IBActions

    // MARK: - @objc

    // MARK: - Functions
    private func registerNib() {
        userTableView.register(UINib(nibName: "UserInfoHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "UserInfoHeaderView")
        userTableView.register(UINib(nibName: "MyInfoHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MyInfoHeaderView")
        userTableView.register(UINib(nibName: "UserInfoBaseCell", bundle: nil), forCellReuseIdentifier: "UserInfoBaseCell")
    }

    private func myInfoCellDidSelectActions(cellType: MyInfoCellType) {
        switch cellType {
        case .eraseAllData:
            guard let eraseAllDataViewController = storyboard?.instantiateViewController(withIdentifier: "EraseAllDataViewController") as? EraseAllDataViewController
            else { return }
            eraseAllDataViewController.viewModel = viewModel

            navigationController?.pushViewController(eraseAllDataViewController, animated: true)
        case .changeGoal:
            performSegue(withIdentifier: "changeGoalSegue", sender: self)
            return
        case .editUserInfo:
            let prevViewModel = viewModel
            viewModel.editUserInfo(gender: "남", age: 99, height: 180, weight: 80, nickname: "신선도사")
            viewModel.save { [weak self] (isSaved) in
                DispatchQueue.main.async {
                    var alert = UIAlertController()
                    if isSaved {
                        alert = UIAlertController.simpleAlert(title: "", message: "수정 완료")
                    } else {
                        alert = UIAlertController.simpleAlert(title: "", message: "수정 실패")
                        self?.viewModel = prevViewModel
                    }
                    self?.present(alert, animated: true) {
                        self?.userTableView.reloadData()
                    }
                }
            }
        case .notificationSetting:
            guard let url = URL(string: UIApplication.openSettingsURLString)
            else {
                let alert = UIAlertController.simpleAlert(title: "오류", message: "알 수 없는 오류로 인하여 알람 설정을 할 수 없어요")
                present(alert, animated: true, completion: nil)

                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        case .myInfo: return cellIdentifier.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = sectionType(rawValue: section)
        else { return UIView() }

        var header: UITableViewHeaderFooterView?

        switch sectionType {
        case .userHeader:
            guard let headerView = userTableView.dequeueReusableHeaderFooterView(withIdentifier: "UserInfoHeaderView") as? UserInfoHeaderView
            else { return nil }

            headerView.configure(viewModel: viewModel)

            header = headerView
        case .myInfo:
            guard let headerView = userTableView.dequeueReusableHeaderFooterView(withIdentifier: "MyInfoHeaderView") as? MyInfoHeaderView
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
            guard let customCell = userTableView.dequeueReusableCell(withIdentifier: "UserInfoBaseCell") as? UserInfoBaseCell,
                  let cellType = MyInfoCellType(rawValue: indexPath.row)
            else { return UITableViewCell() }

            customCell.configure(title: cellType.title())

            cell = customCell
        }

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
            return userHeaderHeight
        case .myInfo:
            return myInfoHeaderHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight: CGFloat = cellHeight

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
