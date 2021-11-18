import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum KeyValue: String {
        case isUserInfoSaved = "isUserInfoSaved"
        case main = "Main"
        case enroll = "enroll"
        case mainNavigation = "MainNavigationViewController"
        case enrollNavigation = "EnrollNavigationViewController"
    }

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let isSaved = UserDefaults.standard.bool(forKey: KeyValue.isUserInfoSaved.rawValue)
        let mainStoryboard = UIStoryboard(name: KeyValue.main.rawValue, bundle: nil)
        let enrollStoryboard = UIStoryboard(name: KeyValue.enroll.rawValue, bundle: nil)
        let mainViewController = mainStoryboard.instantiateViewController(withIdentifier: KeyValue.mainNavigation.rawValue)
        let enrollViewController = enrollStoryboard.instantiateViewController(withIdentifier: KeyValue.enrollNavigation.rawValue)

        guard let scene = scene as? UIWindowScene
        else { return }
        window = UIWindow(windowScene: scene)

        switch isSaved {
        case true:
            window?.rootViewController = mainViewController
        case false:
            window?.rootViewController = enrollViewController
        }
    }
}
