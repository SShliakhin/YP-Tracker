struct AnalyticsEvent {
	enum EventType: CustomStringConvertible {
		case screenOpen
		case screenClose
		case click(ClickType)

		var description: String {
			switch self {
			case .screenOpen:
				return Appearance.open
			case .screenClose:
				return Appearance.close
			case .click:
				return Appearance.click
			}
		}
	}

	enum ScreenName: String {
		case main = "Main"
	}

	enum ClickType: String {
		case addTrack = "add_track"
		case track
		case filter
		case edit
		case delete
	}

	let type: EventType
	let screen: ScreenName
}

private extension AnalyticsEvent {
	enum Appearance {
		static let open = "open"
		static let close = "close"
		static let click = "click"
	}
}
