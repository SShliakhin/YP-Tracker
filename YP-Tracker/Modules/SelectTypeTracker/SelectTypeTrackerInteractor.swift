enum EventSelectTypeTrackerInteractor {
	case selectType(Tracker.TrackerType)
}

protocol ISelectTypeTrackerInteractor: AnyObject {
	func didUserDo(request: SelectTypeTrackerModels)

	var didSendEventClosure: ((EventSelectTypeTrackerInteractor) -> Void)? { get set }
}

final class SelectTypeTrackerInteractor: ISelectTypeTrackerInteractor {
	var didSendEventClosure: ((EventSelectTypeTrackerInteractor) -> Void)?

	func didUserDo(request: SelectTypeTrackerModels) {
		switch request {
		case let .selectType(type):
			didSendEventClosure?(.selectType(type))
		}
	}
}
