//
//  GraphView.swift
//  Calculator
//
//  Created by Esten on 20/05/16.
//  Copyright © 2016 Esten. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    @IBInspectable
    var scale: Float = 1.0
    @IBInspectable
    private var axisColor: UIColor = UIColor.blueColor()
    
    override func drawRect(rect: CGRect) {
        drawAxis()
        drawSkull()
    }
    
    private func drawSkull() {
        let skullRadius = min(bounds.size.width, bounds.size.height) / 2
        let skullCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let skull = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2*M_PI), clockwise: false)
        skull.lineWidth = 5.0
        UIColor.blueColor().set()
        skull.stroke()
    }
    
    private func drawAxis() {
        axisColor.set()
        getStraightPathFrom(CGPoint(x: bounds.midX, y: 0), to: CGPoint(x: bounds.midX, y: bounds.maxY), withLineWidth: 1.0).stroke()
        getStraightPathFrom(CGPoint(x: 0, y: bounds.midY), to: CGPoint(x: bounds.maxX, y: bounds.midX), withLineWidth: 1.0).stroke()
    }
    
    // Last param name
    private func getStraightPathFrom(start: CGPoint, to end: CGPoint, withLineWidth lineWidth: Float = 1.0) -> UIBezierPath {
        let path = UIBezierPath()
        print("Moving point to \(start)")
        path.moveToPoint(start)
        print("Moving point to \(end)")
        path.moveToPoint(end)
        path.lineWidth = CGFloat(lineWidth)
        UIColor.blueColor().set()
        return path
    }
}
