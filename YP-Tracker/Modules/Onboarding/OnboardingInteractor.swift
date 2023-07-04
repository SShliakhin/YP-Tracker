enum EventOnboardingInteractor {
	case finishOnboarding
}

protocol IOnboardingInteractor: AnyObject {
	func didUserDo(request: EventOnboardingInteractor)

	var didSendEventClosure: ((EventOnboardingInteractor) -> Void)? { get set }
}

final class OnboardingInteractor: IOnboardingInteractor {
	var didSendEventClosure: ((EventOnboardingInteractor) -> Void)?

	func didUserDo(request: EventOnboardingInteractor) {
		didSendEventClosure?(request)
	}
}
