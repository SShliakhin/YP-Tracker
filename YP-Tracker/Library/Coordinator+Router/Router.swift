import UIKit

final class Router: NSObject, IRouter {
	private weak var rootController: UINavigationController?
	private var completions: [UIViewController : () -> Void]

	init(rootController: UINavigationController) {
		self.rootController = rootController
		completions = [:]
	}

	func toPresent() -> UIViewController? {
		return rootController
	}

	func present(_ module: Presentable?) {
		present(module, animated: true)
	}

	func present(_ module: Presentable?, animated: Bool) {
		present(module, animated: animated, onDismiss: nil)
	}

	func present(_ module: Presentable?, animated: Bool, onDismiss: (() -> Void)?) {
		guard let controller = module?.toPresent() else { return }
		if let onDismiss = onDismiss {
			completions[controller] = onDismiss
			controller.presentationController?.delegate = self
		}
		rootController?.present(controller, animated: animated, completion: nil)
	}

	func dismissModule() {
		dismissModule(animated: true, completion: nil)
	}

	func dismissModule(animated: Bool, completion: (() -> Void)?) {
		if let controller = rootController?.presentedViewController {
			completions.removeValue(forKey: controller)
		}
		rootController?.dismiss(animated: animated, completion: completion)
	}

	func push(_ module: Presentable?) {
		push(module, animated: true)
	}

	func push(_ module: Presentable?, hideBottomBar: Bool) {
		push(module, animated: true, hideBottomBar: hideBottomBar, completion: nil)
	}

	func push(_ module: Presentable?, animated: Bool) {
		push(module, animated: animated, completion: nil)
	}

	func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
		push(module, animated: animated, hideBottomBar: false, completion: completion)
	}

	func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?) {
		guard
			let controller = module?.toPresent(),
			(controller is UINavigationController == false)
		else { assertionFailure("Deprecated push UINavigationController."); return }

		if let completion = completion {
			completions[controller] = completion
		}
		controller.hidesBottomBarWhenPushed = hideBottomBar
		rootController?.pushViewController(controller, animated: animated)
	}

	func popModule() {
		popModule(animated: true)
	}

	func popModule(animated: Bool) {
		if let controller = rootController?.popViewController(animated: animated) {
			runCompletion(for: controller)
		}
	}

	func setRootModule(_ module: Presentable?) {
		setRootModule(module, hideBar: false)
	}

	func setRootModule(_ module: Presentable?, hideBar: Bool) {
		guard let controller = module?.toPresent() else { return }
		rootController?.setViewControllers([controller], animated: false)
		rootController?.isNavigationBarHidden = hideBar
	}

	func popToRootModule(animated: Bool) {
		if let controllers = rootController?.popToRootViewController(animated: animated) {
			controllers.forEach { controller in
				runCompletion(for: controller)
			}
		}
	}

	private func runCompletion(for controller: UIViewController) {
		guard let completion = completions[controller] else { return }
		completion()
		completions.removeValue(forKey: controller)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension Router: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		runCompletion(for: presentationController.presentedViewController)
	}
}
