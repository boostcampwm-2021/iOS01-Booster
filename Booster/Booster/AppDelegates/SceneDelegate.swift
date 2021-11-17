import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let isSaved = UserDefaults.standard.bool(forKey: "isUserInfoSaved")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let enrollStoryboard = UIStoryboard(name: "Enroll", bundle: nil)
        let mainViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationViewController")
        let enrollViewController = enrollStoryboard.instantiateViewController(withIdentifier: "EnrollNavigationViewController")

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
