//
//  ViewController.swift
//  YP-Tracker
//
//  Created by SERGEY SHLYAKHIN on 04.04.2023.
//

import UIKit

final class ViewController: UIViewController {

	private lazy var welcomeLabel = makeWelcomeLabel()

	// MARK: - Init
	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setupConstraints()
	}
}

// MARK: - UI
private extension ViewController {
	func setup() {}
	func applyStyle() {
		view.backgroundColor = Appearance.backgroundColor
	}
	func setupConstraints() {
		[
			welcomeLabel
		].forEach { item in
			item.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(item)
		}

		welcomeLabel.makeEqualToSuperviewCenter()
	}
}

// MARK: - UI make
private extension ViewController {
	func makeWelcomeLabel() -> UILabel {
		let label = UILabel()
		label.text = Appearance.welcomeText
		label.font = Theme.font(style: .preferred(style: .largeTitle))
		return label
	}
}

// MARK: - Appearance
private extension ViewController {
	enum Appearance {
		static let welcomeText = "Welcome to YP-Tracker"
		static let backgroundColor = UIColor.orange
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ViewProvider: PreviewProvider {
	static var previews: some View {

		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 34.0)
		label.text = "Welcome"

		let label34 = UILabel()
		label34.font = Theme.font(style: .bold34)
		label34.text = "Welcome"

		let label32 = UILabel()
		label32.font = Theme.font(style: .bold32)
		label32.text = "Welcome"

		let label19 = UILabel()
		label19.font = Theme.font(style: .bold19)
		label19.text = "Welcome"

		let label17 = UILabel()
		label17.font = Theme.font(style: .regular17)
		label17.text = "Welcome"

		let label16 = UILabel()
		label16.font = Theme.font(style: .medium16)
		label16.text = "Welcome"

		let label12 = UILabel()
		label12.font = Theme.font(style: .medium12)
		label12.text = "Welcome"

		let label10 = UILabel()
		label10.font = Theme.font(style: .medium10)
		label10.text = "Welcome"

		return Group {
			VStack(spacing: 0) {
				(label as UIView).preview().frame(height: 40)
				(label34 as UIView).preview().frame(height: 40)
				(label32 as UIView).preview().frame(height: 40)
				(label19 as UIView).preview().frame(height: 40)
				(label17 as UIView).preview().frame(height: 40)
				(label16 as UIView).preview().frame(height: 40)
				(label12 as UIView).preview().frame(height: 40)
				(label10 as UIView).preview().frame(height: 40)
			}
		}
	}
}
#endif
