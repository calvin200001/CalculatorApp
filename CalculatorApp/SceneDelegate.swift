//
//  SceneDelegate.swift
//  CalculatorApp
//
//  Created by Joshua Kaplan on 2/28/25.
//  Copyright © 2025 Joshua Kaplan. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate scene(_:willConnectTo:) called") // DEBUG
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // --- Programmatic UI Setup ---
        // guard let windowScene = (scene as? UIWindowScene) else { return } // Removed duplicate guard

        let window = UIWindow(windowScene: windowScene)

        // Instantiate the root view controller programmatically
        let rootViewController = ViewController()

        // Optional: Embed in a UINavigationController if needed (e.g., for history push)
        window.rootViewController = UINavigationController(rootViewController: rootViewController) // Uncommented for Navigation
        // window.rootViewController = rootViewController // Commented out direct assignment

        self.window = window
        print("SceneDelegate making window key and visible...") // DEBUG
        window.makeKeyAndVisible()
        // --- End Programmatic UI Setup ---

        // Removed Storyboard loading code below
        // window = UIWindow(windowScene: windowScene)
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //
        // if let initialViewController = storyboard.instantiateInitialViewController() {
        //     window?.rootViewController = initialViewController
        // }
        //
        // window?.makeKeyAndVisible()
        // window?.backgroundColor = .white // Set a default background color
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
}