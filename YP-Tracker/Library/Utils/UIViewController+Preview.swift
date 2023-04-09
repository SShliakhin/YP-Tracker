//
//  UIViewController+Preview.swift
//  YP-Tracker
//
//  Created by SERGEY SHLYAKHIN on 04.04.2023.
//

#if canImport(SwiftUI) && DEBUG
import SwiftUI

extension UIViewController {
	struct Preview: UIViewControllerRepresentable {
		let viewController: UIViewController

		func makeUIViewController(context: Context) -> some UIViewController {
			viewController
		}

		func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
	}

	func preview() -> some View {
		Preview(viewController: self).edgesIgnoringSafeArea(.all)
	}
}
#endif
