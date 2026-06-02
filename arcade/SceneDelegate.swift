//
//  SceneDelegate.swift
//  arcade
//
//  Created by 김태준 on 5/27/26.
//

import UIKit

/// 씬 생명주기를 관리한다.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// 현재 씬의 메인 윈도우.
    var window: UIWindow?


    /// 씬이 연결될 때 호출된다.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    /// 씬이 시스템에 의해 해제될 때 호출된다.
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    /// 비활성 상태에서 활성 상태로 전환될 때 호출된다.
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    /// 활성 상태에서 비활성 상태로 전환되기 직전에 호출된다.
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    /// 백그라운드에서 포그라운드로 전환될 때 호출된다.
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    /// 포그라운드에서 백그라운드로 전환될 때 호출된다.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
