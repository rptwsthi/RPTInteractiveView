//
//  File.swift
//  RPTInteractiveView_Example
//
//  Created by Arpit on 2/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import UIKit

open class RPTInteractiveView : UIView {
    //MARK: PANNING
    var dataSource : LExSViewDataSource? {
        didSet {
            configureForPanning()
        }
    }
    
    var panArea : CGRect?
    var panParentView : UIView?
    @IBInspectable open var stickToEdges: Bool = true
    @IBInspectable open var verticalLock: Bool = false
    @IBInspectable open var horizontalLock: Bool = false
    @IBInspectable open var shouldScale: Bool = true {
        didSet {
            if shouldScale == true {
                self.configurePinch()
            }
        }
    }
    @IBInspectable open var shouldRotate: Bool = true {
        didSet {
            if shouldRotate == true {
                self.configureRotate()
            }
        }
    }
    @IBInspectable open var shouldPan: Bool = true {
        didSet {
            if shouldPan == true {
                self.configurePan()
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.configureForPanning()
    }
    
    func configureForPanning() {
        if let pa = self.dataSource?.panAreaFor(interactiveView: self) {
            self.panArea = self.finalPanArea(area:pa)
        }
        
        self.panParentView = self.superview
    }
    
    func configurePan () {
        //..
        let recognizer = UIPanGestureRecognizer(target: self,
                                                action:#selector(mePanned(recognizer:)))
        self.addGestureRecognizer(recognizer)
    }
    
    func configurePinch () {
        //..
        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(scale))
        self.addGestureRecognizer(recognizer)
    }
    
    func configureRotate () {
        let recognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        self.addGestureRecognizer(recognizer)
    }
    
    
    func finalPanArea (area : CGRect) -> CGRect {
        var pA = area
        pA.origin.x = pA.origin.x + self.frame.size.width / 2
        pA.origin.y = pA.origin.y + self.frame.size.height / 2
        
        pA.size.width = pA.size.width - self.frame.size.width / 2
        pA.size.height = pA.size.height - self.frame.size.height / 2
        return pA
    }
    
    @objc func mePanned(recognizer: UIPanGestureRecognizer) {
        var point = recognizer.location(in: self.panParentView)
        if (verticalLock) {point.y = self.center.y}
        if (horizontalLock) {point.x = self.center.x}
        self.center = point
        
        switch recognizer.state {
        case .ended:
            if self.stickToEdges {
                UIView.animate(withDuration: 0.15) {
                    if (self.center.x < UIScreen.main.bounds.size.width / 2) {
                        self.center.x = 56
                    }else{
                        self.center.x = UIScreen.main.bounds.size.width - 56
                    }
                }
            }
            break
            
        default:
            break
        }
    }
    var identity = CGAffineTransform.identity
    @objc func scale(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            identity = self.transform
        case .changed,.ended:
            self.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
        case .cancelled:
            break
        default:
            break
        }
    }
    
    @objc func rotate(_ gesture: UIRotationGestureRecognizer) {
        self.transform = self.transform.rotated(by: gesture.rotation)
    }
    
    func goingOutOfPanBound(point:CGPoint) -> Bool {
        guard let pa = self.panArea else {return false}
        return ( point.x < pa.origin.x ||
            point.y < pa.origin.y ||
            point.x > pa.size.width ||
            point.y > pa.size.height)
    }
    
    @objc func mePinched(recognizer: UIPinchGestureRecognizer) {
    }
}

protocol LExSViewDataSource {
    func panAreaFor(interactiveView:RPTInteractiveView) -> CGRect?
}

