// MARK: - ServicesFactory

import Foundation

protocol IServiceFactory {
	func makeLocalFilesProvider() -> FileManager
}

extension Di: IServiceFactory {
	func makeLocalFilesProvider() -> FileManager {
		FileManager.default
	}
}
