// MARK: - ServicesFactory

import Foundation

protocol ServicesFactory {
	func makeLocalFilesProvider() -> FileManager
}

extension Di: ServicesFactory {
	func makeLocalFilesProvider() -> FileManager {
		FileManager.default
	}
}
