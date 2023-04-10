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
		case bold34
		case bold32
		case bold19
		case regular17
		case medium16
		case medium12
		case medium10
	}

	static func font(style: FontStyle) -> UIFont {
		let customFont: UIFont

		switch style {
		case let .preferred(style: style):
			customFont = UIFont.preferredFont(forTextStyle: style)
		case .bold34:
			customFont = UIFont(name: "YSDisplay-Bold", size: 34.0) ?? UIFont.systemFont(ofSize: 34.0)
		case .bold32:
			customFont = UIFont(name: "YSDisplay-Bold", size: 32.0) ?? UIFont.systemFont(ofSize: 32.0)
		case .bold19:
			customFont = UIFont(name: "YSDisplay-Bold", size: 19.0) ?? UIFont.systemFont(ofSize: 19.0)
		case .regular17:
			customFont = UIFont(name: "YandexSansDisplay-Regular", size: 17.0) ?? UIFont.systemFont(ofSize: 17.0)
		case .medium16:
			customFont = UIFont(name: "YSDisplay-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
		case .medium12:
			customFont = UIFont(name: "YSDisplay-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
		case .medium10:
			customFont = UIFont(name: "YSDisplay-Medium", size: 10.0) ?? UIFont.systemFont(ofSize: 10.0)
		}
		return customFont
	}

	// MARK: - Colors
	private enum FlatColor {
		enum Tracker {
			static let red = UIColor(hex: 0xFD4C49)
			static let lightOrange = UIColor(hex: 0xFF881E)
			static let blue = UIColor(hex: 0x007BFA)
			static let purple = UIColor(hex: 0x6E44FE)
			static let green = UIColor(hex: 0x33CF69)
			static let lightPurple = UIColor(hex: 0xE66DD4)
			static let lightPink = UIColor(hex: 0xF9D4D4)
			static let lightBlue = UIColor(hex: 0x34A7FE)
			static let lightGreen = UIColor(hex: 0x46E69D)
			static let indigo = UIColor(hex: 0x35347C)
			static let orange = UIColor(hex: 0xFF674D)
			static let pink = UIColor(hex: 0xFF99CC)
			static let paleOrange = UIColor(hex: 0xF6C48B)
			static let paleBlue = UIColor(hex: 0x7994F5)
			static let brightPurple = UIColor(hex: 0x832CF1)
			static let paleIndigo = UIColor(hex: 0xAD56DA)
			static let palePurple = UIColor(hex: 0x8D72E6)
			static let brightGreen = UIColor(hex: 0x2FD058)
		}

		enum DayNight {
			static let black = UIColor(hex: 0x1A1B22)
			static let white = UIColor(hex: 0xFFFFFF)
			static let gray = UIColor(hex: 0xAEAFB4)
			static let lightGray = UIColor(hex: 0xE6E8EB)
			static let backgroundDay = UIColor(hex: 0xE6E8EB)
			static let backgroundNight = UIColor(hex: 0x414141)
			static let red = UIColor(hex: 0xF56B6C)
			static let blue = UIColor(hex: 0x3772E7)
		}
	}

	static func getTrackerColors() -> [UIColor] {
		[
			FlatColor.Tracker.red,
			FlatColor.Tracker.lightOrange,
			FlatColor.Tracker.blue,
			FlatColor.Tracker.purple,
			FlatColor.Tracker.green,
			FlatColor.Tracker.lightPurple,
			FlatColor.Tracker.lightPink,
			FlatColor.Tracker.lightBlue,
			FlatColor.Tracker.lightGreen,
			FlatColor.Tracker.indigo,
			FlatColor.Tracker.orange,
			FlatColor.Tracker.pink,
			FlatColor.Tracker.paleOrange,
			FlatColor.Tracker.paleBlue,
			FlatColor.Tracker.brightPurple,
			FlatColor.Tracker.paleIndigo,
			FlatColor.Tracker.palePurple,
			FlatColor.Tracker.brightGreen
		]
	}

	enum Color {
		case main
		case accent
		case background
		case attention
		case white
		case black
		case gray
		case lightGray
	}

	static func color(usage: Color) -> UIColor {
		let customColor: UIColor

		switch usage {
		case .main:
			customColor = UIColor.color(light: FlatColor.DayNight.black, dark: FlatColor.DayNight.white)
		case .accent:
			customColor = FlatColor.DayNight.blue
		case .background:
			customColor = UIColor.color(
				light: FlatColor.DayNight.backgroundDay.withAlphaComponent(30.0),
				dark: FlatColor.DayNight.backgroundNight.withAlphaComponent(85.0)
			)
		case .attention:
			customColor = FlatColor.DayNight.red
		case .white:
			customColor = UIColor.color(light: FlatColor.DayNight.white, dark: FlatColor.DayNight.black)
		case .black:
			customColor = UIColor.color(light: FlatColor.DayNight.black, dark: FlatColor.DayNight.white)
		case .gray:
			customColor = FlatColor.DayNight.gray
		case .lightGray:
			customColor = FlatColor.DayNight.lightGray
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
