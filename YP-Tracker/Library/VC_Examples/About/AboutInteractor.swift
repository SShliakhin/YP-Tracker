import UIKit
protocol IAboutInteractor {
	/// Возвращает строковые данные из файла, указанного в константах
	func viewIsReady()
}

final class AboutInteractor {
	private var worker: IAboutWorker
	private let presenter: IAboutPresenter
	private let localFilesProvider: FileManager

	init(
		worker: IAboutWorker,
		presenter: IAboutPresenter,
		dep: IAboutModuleDependency
	) {
		self.worker = worker
		self.presenter = presenter
		localFilesProvider = dep.localFilesProvider
	}
}

// MARK: - IAboutInteractor

extension AboutInteractor: IAboutInteractor {
	func viewIsReady() {
		if let aboutFileText = worker.readFile(fileManager: localFilesProvider) {
			presenter.present(text: aboutFileText)
		}
	}
}
