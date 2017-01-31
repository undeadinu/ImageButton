//
//  TintStateImages.swift
//  ImageButton
//
//  Created by Dmitry Nikolaev on 04.05.15.
//  Copyright (c) 2015 Dmitry Nikolaev. All rights reserved.
//

import AppKit


open class TintTextImageButtonBuilder {
    
    open var height: CGFloat
    
    open var defaultColor: NSColor = NSColor.black
    open var overColor: NSColor = NSColor.yellow
    open var pressedColor: NSColor = NSColor.red
    open var disabledColor: NSColor = NSColor.gray
    
    open var font = NSFont(name: "Helvetica Neue", size: 13)
    open var textXOffset = CGFloat(0.0)
    open var textYOffset = CGFloat(0.0)

    public init(height: CGFloat) {
        self.height = height
    }
    
    open func buildImagesWithImage(_ image: NSImage, text: String) -> ImageButtonImages {
        let textSize = self.textSize(text)
        let width = image.size.width + self.textXOffset + textSize.width;
        let midY = self.height / 2
        let imagePoint = NSPoint(x: 0, y: midY - image.size.height / 2)
        let textPoint = NSPoint(x: image.size.width + self.textXOffset, y: textYOffset)
        
        let templateImage = NSImage(size: NSMakeSize(width , height))
        templateImage.lockFocus()
        
        image.draw(at: imagePoint, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1)
        (text as NSString).draw(at: textPoint, withAttributes: self.textAttributes())
        templateImage.unlockFocus()
        
        let result = ImageButtonImages()
        result.defaultImage = templateImage.imageWithTint(self.defaultColor)
        result.overImage = templateImage.imageWithTint(self.overColor)
        result.pressedImage = templateImage.imageWithTint(self.pressedColor)
        result.disabledImage = templateImage.imageWithTint(self.disabledColor)
        return result
    }
    
    fileprivate func textAttributes(_ color: NSColor? = nil) -> [String : AnyObject] {
        var result = [String : AnyObject]()
        result[NSFontAttributeName] = self.font!
        if color != nil {
            result[NSForegroundColorAttributeName] = color!
        }
        
        return result
    }
    
    fileprivate func textSize(_ text: String) -> NSSize {
        let string = text as NSString
        let size = string.size(withAttributes: self.textAttributes())
        return size
    }

}

public extension ImageButton {
    public convenience init(image: NSImage, text: String, height: CGFloat, defaultColor: NSColor, overColor: NSColor, pressedColor: NSColor, disabledColor: NSColor, font: NSFont, textXOffset: CGFloat, textYOffset: CGFloat) {
        let imageBuilder = TintTextImageButtonBuilder(height: height)
        imageBuilder.defaultColor = defaultColor
        imageBuilder.overColor = overColor
        imageBuilder.pressedColor = pressedColor
        imageBuilder.disabledColor = disabledColor
        imageBuilder.font = font
        imageBuilder.textXOffset = textXOffset
        imageBuilder.textYOffset = textYOffset
        self.init(images: imageBuilder.buildImagesWithImage(image, text: text))
    }
}


