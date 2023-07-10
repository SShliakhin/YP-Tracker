import YandexMobileMetrica

final class AnalyticsService {
	static func activate() {
		guard let configuration = YMMYandexMetricaConfiguration(
			apiKey: "5077f1f0-5173-4ed1-90fc-da767a9a1861"
		) else { return }

		configuration.crashReporting = false

		YMMYandexMetrica.activate(with: configuration)
	}

	func report(event: String, params: [AnyHashable: Any]) {
		YMMYandexMetrica.reportEvent(
			event,
			parameters: params,
			onFailure: { error in
				print("REPORT ERROR: %@", error.localizedDescription)
			}
		)
	}
}
