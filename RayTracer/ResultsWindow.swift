//
// Ray caster/tracer skeleton code and scene files adapted from starter code
// provided by MIT 6.837 on OCW.
//
// All additional code written by Dion Larson unless noted otherwise.
//
// Original skeleton code available for free here (assignments 4 & 5):
// http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-837-computer-graphics-fall-2012/
//
// Licensed under Creative Commons 4.0 (Attribution, Noncommercial, Share Alike)
// http://creativecommons.org/licenses/by-nc-sa/4.0/
//

import Foundation
import Cocoa

class ResultsWindowController: NSWindowController {
    
    static var windowNumber = 0
    var wNumber: Int {
        return ResultsWindowController.windowNumber
    }

    @IBOutlet var resultsWindow: ResultsWindow!
    
    convenience init(windowTitle: String) {
        self.init(windowNibName: "ResultsWindow")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.showWindow(self)
            self.resultsWindow.orderBack(self)
            self.resultsWindow.title = windowTitle
            self.resultsWindow.cascadeTopLeftFromPoint(NSPoint(x: self.wNumber * 25, y: self.wNumber * 25))
            ResultsWindowController.windowNumber++
        }
    }
    
    func updateStatusLabel(stage: String, scene: SceneFile)  {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if let resultsWindow = self.resultsWindow {
                resultsWindow.statusLabel.stringValue = "\(stage) \(scene)..."
            }
        }
    }
    
    func updateImageView(image: NSImage) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if let resultsWindow = self.resultsWindow {
                resultsWindow.imageView.image = image
                resultsWindow.makeKeyAndOrderFront(self)
            }
        }
    }
}

class ResultsWindow: NSWindow {
    
    @IBOutlet private weak var statusLabel: NSTextField!
    @IBOutlet private weak var imageView: NSImageView!
    
    var rendered: NSImage?
    var depth: NSImage?
    var normals: NSImage?
    
    override func keyDown(theEvent: NSEvent) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            switch theEvent.keyCode {
            case 2: // d
                self.imageView.image = self.depth
            case 34: // i
                self.imageView.image = self.rendered
            case 45: // n
                self.imageView.image = self.normals
            default:
                break
            }
        }
    }
    
}