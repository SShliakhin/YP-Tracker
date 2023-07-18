import UIKit

extension UIImage {
	static func gradientImage(
		bounds: CGRect,
		colors: [UIColor],
		direction: GradientDirection
	) -> UIImage {
		let gradientLayer = CAGradientLayer()

		gradientLayer.frame = bounds
		gradientLayer.colors = colors.map(\.cgColor)
		gradientLayer.startPoint = direction.startPoint
		gradientLayer.endPoint = direction.endPoint

		let renderer = UIGraphicsImageRenderer(bounds: bounds)

		return renderer.image { ctx in
			gradientLayer.render(in: ctx.cgContext)
		}
	}
}
