import UIKit

extension UIImage {
    
    func setText(_ text: String) -> UIImage {
        let point = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        return self.addText(text, atPoint: point, textColor: UIColor.black, textFont: nil)
    }
    
    func addText(_ drawText: String, atPoint: CGPoint, textColor: UIColor?, textFont: UIFont?) -> UIImage {
        
        // Setup the font specific variables
        var _textColor: UIColor
        if textColor == nil {
            _textColor = UIColor.white
        } else {
            _textColor = textColor!
        }
        
        var _textFont: UIFont
        if textFont == nil {
            _textFont = UIFont.systemFont(ofSize: 16)
        } else {
            _textFont = textFont!
        }
        
        // Setup the image context using the passed image
        UIGraphicsBeginImageContext(size)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: _textFont,
            NSForegroundColorAttributeName: _textColor
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: size.width, height: size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
        let newImage  :UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}
