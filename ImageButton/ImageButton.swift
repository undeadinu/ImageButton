//
//  ImageButton.swift
//  Numi
//
//  Created by Dmitry Nikolaev on 02.12.14.
//  Copyright (c) 2014 Dmitry Nikolaev. All rights reserved.
//

import Foundation
import AppKit

@objc
open class ImageButton: NSView {
    
    open var images: ImageButtonImages? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
        }
    }
    
    open var delegate: ImageButtonDelegate?
    open var action: Optional<() -> ()>
    open var enabled: Bool = true {
        didSet {
            self.needsDisplay = true
        }
    }

    open var mouseOver = false
    open var pressed = false
    open var debug = false {
        didSet {
            needsDisplay = true
        }
    }

    fileprivate var trackedArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.postInit()
    }
    
    public init(images: ImageButtonImages) {
        self.images = images
        super.init(frame: NSRect(origin: CGPoint(), size: self.images!.defaultImage!.size))
        self.postInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.postInit()
    }
    
    fileprivate func postInit() {
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.setContentCompressionResistancePriority(1000, for: .horizontal)
        self.setContentCompressionResistancePriority(1000, for: .vertical)
        self.setContentHuggingPriority(1000, for: .horizontal)
        self.setContentHuggingPriority(1000, for: .vertical)
    }
    
    open override func updateTrackingAreas() {
        if let trackingArea = self.trackedArea {
            self.removeTrackingArea(trackingArea)
        }
        
        self.trackedArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeAlways, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        self.addTrackingArea(self.trackedArea!)
    }
    
    override open func resetCursorRects() {
        self.addCursorRect(self.bounds, cursor: NSCursor.pointingHand())
    }
    
    open override var intrinsicContentSize: NSSize {
        if #available(OSXApplicationExtension 10.11, *) {
            return (self.images != nil) ? self.images!.defaultImage!.size : NSSize(width: NSViewNoIntrinsicMetric, height: NSViewNoIntrinsicMetric)
        } else {
            return (self.images != nil) ? self.images!.defaultImage!.size : NSSize()
        }
    }
    
    // MARK: Mouse
    
    override open func mouseEntered(with theEvent: NSEvent) {
        self.mouseOver = true
        self.needsDisplay = true
        if self.enabled {
            self.delegate?.imageButtonMouseEnter(self)
        }
    }
    
    override open func mouseExited(with theEvent: NSEvent) {
        self.mouseOver = false
        self.needsDisplay = true
        if self.enabled {
            self.delegate?.imageButtonMouseExit(self)
        }
    }
    
    override open func mouseDown(with theEvent: NSEvent) {
        self.pressed = true
        self.needsDisplay = true
    }
    
    override open func mouseUp(with theEvent: NSEvent) {
        
        if !self.enabled {
            return
        }
        
        if self.pressed {
            if let action = self.action {
                self.mouseOver = false
                action()
            }
        }
        self.pressed = false
        self.needsDisplay = true
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        
        if debug {
            
            var color = NSColor.yellow
            
            switch state() {
            case .over:
                color = NSColor.green
            case .pressed:
                color = NSColor.red
            default:
                color = NSColor.yellow
            }
            
            color.setFill()
            NSRectFill(bounds)
        }
        
        let image = self.imageByState(self.state())
        image?.draw(at: NSPoint(), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1)
    }

    fileprivate func state() -> ImageButtonState {
        var state = ImageButtonState.default
        
        if (!self.enabled) {
            state = ImageButtonState.disabled
        } else {
            
            if (self.mouseOver) {
                state = ImageButtonState.over
                if (self.pressed) {
                    state = ImageButtonState.pressed
                }
            }
        }
        return state
    }
    
    fileprivate func imageByState(_ state: ImageButtonState) -> NSImage? {
        let image: NSImage?
        switch state {
        case .default:
            image = self.images?.defaultImage
        case .over:
            image = self.images?.overImage
        case .pressed:
            image = self.images?.pressedImage
        case .disabled:
            image = self.images?.disabledImage
        }
        return image
    }
    
}

@objc
public protocol ImageButtonDelegate {
    func imageButtonMouseEnter(_ button: ImageButton)
    func imageButtonMouseExit(_ button: ImageButton)
}


open class ImageButtonImages {
    open var defaultImage, overImage, pressedImage, disabledImage: NSImage?
}

@objc
public protocol ImageButtonPresentation {
    func drawForButtonState(_ buttonState: ImageButtonState, dirtyRect: NSRect)
    func intrinsicContentSize()->NSSize
}

@objc
public enum ImageButtonState: Int {
    case `default`, over, pressed, disabled
}




