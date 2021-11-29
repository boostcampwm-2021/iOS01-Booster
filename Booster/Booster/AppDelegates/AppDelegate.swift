import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert], completionHandler: { _, _ in
            let boosterUserNotification = BoosterUserNotification()
            if !boosterUserNotification.isAlreadyAdded(type: .morning) { boosterUserNotification.setNotification(requestType: .add, type: .morning)}
        })
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        // 세로방향 고정
        return UIInterfaceOrientationMask.portrait
    }
}
