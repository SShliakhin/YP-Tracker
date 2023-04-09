//
//  Theme.swift
//  YP-Tracker
//
//  Created by SERGEY SHLYAKHIN on 04.04.2023.
//

import UIKit

enum Theme {

	// MARK: - Fonts
	enum FontStyle {
		case preferred(style: UIFont.TextStyle)
	}

	static func font(style: FontStyle) -> UIFont {
		let customFont: UIFont

		switch style {
		case let .preferred(style: style):
			customFont = UIFont.preferredFont(forTextStyle: style)
		}
		return customFont
	}

	// MARK: - Colors
	enum Color {
		case ypRed
		case ypBlue
		case ypGreen
	}

	static func color(usage: Color) -> UIColor {
		let customColor: UIColor

		switch usage {
		case .ypRed:
			customColor = .systemRed
		case .ypBlue:
			customColor = .systemBlue
		case .ypGreen:
			customColor = .systemGreen
		}

		return customColor
	}

	// MARK: - Images
	enum ImageAsset: String {
		case exampleLogo
	}

	static func image(kind: ImageAsset) -> UIImage {
		return UIImage(named: kind.rawValue) ?? .actions // swiftlint:disable:this image_name_initialization
	}

	// MARK: - Spacing
	enum Spacing {
		case standard
		case standard2
		case standardHalf
		case standard4
	}

	static func spacing(usage: Spacing) -> CGFloat {
		let customSpacing: CGFloat

		switch usage {
		case .standard:
			customSpacing = 8
		case .standard2:
			customSpacing = 16
		case .standardHalf:
			customSpacing = 4
		case .standard4:
			customSpacing = 32
		}

		return customSpacing
	}

	// MARK: - Size
	enum Size {
		case cornerRadius
	}

	static func size(kind: Size) -> CGFloat {
		let customSize: CGFloat

		switch kind {
		case .cornerRadius:
			customSize = 10
		}

		return customSize
	}

	// MARK: - DateFormatter
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()
}
