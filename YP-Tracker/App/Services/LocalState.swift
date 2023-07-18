import Foundation
protocol ILocalState {
	var hasOnboarded: Bool? { get set }
}

extension ILocalState {
	var hasOnboardedKey: String { "hasOnboarded" }
}

struct LocalState: ILocalState {
	let localStateStorage: UserDefaults

	var hasOnboarded: Bool? {
		get {
			localStateStorage.bool(forKey: hasOnboardedKey)
		}
		set {
			guard let newValue = newValue else {
				localStateStorage.removeObject(forKey: hasOnboardedKey)
				return
			}
			localStateStorage.set(newValue, forKey: hasOnboardedKey)
		}
	}
}
