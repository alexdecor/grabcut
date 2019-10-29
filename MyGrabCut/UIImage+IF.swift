
import UIKit

func RadiansOfDegrees(_ degrees: CGFloat) -> CGFloat {
    return degrees * .pi / 180
}

extension UIImage {
    public func reSizeImage(reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0.0, y: 0.0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }

    func cropImage(withBounds bounds: CGRect) -> UIImage? {
        var tmpImage: UIImage?
        if let cgImage = cgImage {
            tmpImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        }

        if (imageOrientation == .up) || (imageOrientation == .upMirrored) {
        } else if (imageOrientation == .left) || (imageOrientation == .leftMirrored) {
            tmpImage = tmpImage?.imageRotated(byDegrees: -90.0)
        } else if (imageOrientation == .right) || (imageOrientation == .rightMirrored) {
            tmpImage = tmpImage?.imageRotated(byDegrees: 90.0)
        } else if (imageOrientation == .down) || (imageOrientation == .downMirrored) {
            tmpImage = tmpImage?.imageRotated(byDegrees: 180.0)
        }

        guard let cgImage = tmpImage?.cgImage?.cropping(to: bounds) else { return nil }
        let croppedImage = UIImage(cgImage: cgImage)
        return croppedImage
    }

    func imageRotated(byDegrees degrees: CGFloat) -> UIImage? {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let t = CGAffineTransform(rotationAngle: RadiansOfDegrees(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()

        bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

        bitmap?.rotate(by: RadiansOfDegrees(degrees))

        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    convenience init?(color: UIColor, andRect setRect: CGRect) {
        //    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        self.init()
        let rect = setRect
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
