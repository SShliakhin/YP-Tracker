import YandexMobileMetrica

protocol IAnalyticsService {
	func log(_ event: AnalyticsEvent)
}

// swiftlint:disable:next convenience_type
final class AnalyticsService {
	static func activate() {
		guard let configuration = YMMYandexMetricaConfiguration(
			apiKey: "5077f1f0-5173-4ed1-90fc-da767a9a1861"
		) else { return }

		configuration.crashReporting = false

		YMMYandexMetrica.activate(with: configuration)
	}
}

extension AnalyticsService: IAnalyticsService {
	func log(_ event: AnalyticsEvent) {
		var params: [AnyHashable: Any] = [:]
		params["screen"] = event.screen.rawValue
		if case let .click(clickType) = event.type {
			params["item"] = clickType.rawValue
		}

		report(event: event.type.description, params: params)
	}

	private func report(event: String, params: [AnyHashable: Any]) {
		YMMYandexMetrica.reportEvent(
			event,
			parameters: params,
			onFailure: { error in
				print("REPORT ERROR: %@", error.localizedDescription)
			}
		)
	}
}
