//
//  SceneDelegate.swift
//  Swift-Base
//
//  Created by SERGEY SHLYAKHIN on 04.04.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let scene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: scene)
		window.rootViewController = ViewController()
		self.window = window
		window.makeKeyAndVisible()
	}
}
