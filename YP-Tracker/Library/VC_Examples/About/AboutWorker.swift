import Foundation

protocol IAboutWorker {
	func readFile(fileManager: FileManager) -> String?
}

final class AboutWorker: IAboutWorker {
	func readFile(fileManager: FileManager) -> String? {
		let path = Theme.Constansts.aboutFilePath

		guard let fileContent = fileManager.contents(atPath: path),
			  let fileContentEncoded = String(bytes: fileContent, encoding: .utf8) else { return nil }
		return fileContentEncoded
	}
}
