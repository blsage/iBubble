//
//  iBubble.swift
//  iBubble
//
//  Created by Benjamin Sage on 3/8/25.
//

import SwiftUI

public struct iBubble: Shape {
    public enum CaretEdge: Sendable { case top, right, bottom, left }
    public enum CaretPositionType: Sendable { case normalized, insetFromStart, insetFromEnd }
    
    var cornerRadius: CGFloat
    var caretWidth: CGFloat
    var caretHeight: CGFloat
    var caretCornerRadius: CGFloat
    var caretPosition: CGFloat
    var caretPositionType: CaretPositionType = .normalized
    var edge: CaretEdge
    var caretAngle: Angle = .degrees(0)
    var insetAmount: CGFloat = 0
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        
        if let (caretStartPoint, caretTipPoint, caretEndPoint) = calculateCaretPoints(in: rect) {
            let safeDistanceFromCorner = cornerRadius * 1.5
            let caretBaseCenter = getCaretBaseCenter(in: rect)
            
            // Check if caret is too close to corners
            var skipCaret = false
            switch edge {
            case .top, .bottom:
                if caretBaseCenter.x < rect.minX + safeDistanceFromCorner || 
                   caretBaseCenter.x > rect.maxX - safeDistanceFromCorner {
                    skipCaret = true
                }
            case .left, .right:
                if caretBaseCenter.y < rect.minY + safeDistanceFromCorner || 
                   caretBaseCenter.y > rect.maxY - safeDistanceFromCorner {
                    skipCaret = true
                }
            }
            
            if skipCaret {
                return RoundedRectangle(cornerRadius: cornerRadius - insetAmount, style: .continuous).path(in: rect)
            }
            
            // Create a single continuous path
            switch edge {
            case .top:
                createTopCaretPath(in: rect, path: &path, startPoint: caretStartPoint, tipPoint: caretTipPoint, endPoint: caretEndPoint)
            case .right:
                createRightCaretPath(in: rect, path: &path, startPoint: caretStartPoint, tipPoint: caretTipPoint, endPoint: caretEndPoint)
            case .bottom:
                createBottomCaretPath(in: rect, path: &path, startPoint: caretStartPoint, tipPoint: caretTipPoint, endPoint: caretEndPoint)
            case .left:
                createLeftCaretPath(in: rect, path: &path, startPoint: caretStartPoint, tipPoint: caretTipPoint, endPoint: caretEndPoint)
            }
        } else {
            path = RoundedRectangle(cornerRadius: cornerRadius - insetAmount, style: .continuous).path(in: rect)
        }
        
        return path
    }
    
    private func createTopCaretPath(in rect: CGRect, path: inout Path, startPoint: CGPoint, tipPoint: CGPoint, endPoint: CGPoint) {
        let cornerRadius = self.cornerRadius - insetAmount
        
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.addLine(to: startPoint)
        
        if caretCornerRadius > 0 {
            let tipRadius = min(caretCornerRadius, caretWidth/4, caretHeight/4)
            drawRoundedTip(path: &path, from: startPoint, through: tipPoint, to: endPoint, radius: tipRadius)
        } else {
            path.addLine(to: tipPoint)
            path.addLine(to: endPoint)
        }
        
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
    }
    
    private func createRightCaretPath(in rect: CGRect, path: inout Path, startPoint: CGPoint, tipPoint: CGPoint, endPoint: CGPoint) {
        let cornerRadius = self.cornerRadius - insetAmount
        
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))
        path.addLine(to: startPoint)
        
        if caretCornerRadius > 0 {
            let tipRadius = min(caretCornerRadius, caretWidth/4, caretHeight/4)
            drawRoundedTip(path: &path, from: startPoint, through: tipPoint, to: endPoint, radius: tipRadius)
        } else {
            path.addLine(to: tipPoint)
            path.addLine(to: endPoint)
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
    }
    
    private func createBottomCaretPath(in rect: CGRect, path: inout Path, startPoint: CGPoint, tipPoint: CGPoint, endPoint: CGPoint) {
        let cornerRadius = self.cornerRadius - insetAmount
        
        path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.addLine(to: startPoint)
        
        if caretCornerRadius > 0 {
            let tipRadius = min(caretCornerRadius, caretWidth/4, caretHeight/4)
            drawRoundedTip(path: &path, from: startPoint, through: tipPoint, to: endPoint, radius: tipRadius)
        } else {
            path.addLine(to: tipPoint)
            path.addLine(to: endPoint)
        }
        
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
    }
    
    private func createLeftCaretPath(in rect: CGRect, path: inout Path, startPoint: CGPoint, tipPoint: CGPoint, endPoint: CGPoint) {
        let cornerRadius = self.cornerRadius - insetAmount
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        path.addLine(to: startPoint)
        
        if caretCornerRadius > 0 {
            let tipRadius = min(caretCornerRadius, caretWidth/4, caretHeight/4)
            drawRoundedTip(path: &path, from: startPoint, through: tipPoint, to: endPoint, radius: tipRadius)
        } else {
            path.addLine(to: tipPoint)
            path.addLine(to: endPoint)
        }
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
    }
    
    private func getCaretBaseCenter(in rect: CGRect) -> CGPoint {
        switch edge {
        case .top:
            let x: CGFloat
            switch caretPositionType {
            case .normalized:
                let positionFactor = max(0, min(1, caretPosition))
                x = rect.minX + rect.width * positionFactor
            case .insetFromStart:
                x = rect.minX + caretPosition
            case .insetFromEnd:
                x = rect.maxX - caretPosition
            }
            return CGPoint(x: x, y: rect.minY)
            
        case .right:
            let y: CGFloat
            switch caretPositionType {
            case .normalized:
                let positionFactor = max(0, min(1, caretPosition))
                y = rect.minY + rect.height * positionFactor
            case .insetFromStart:
                y = rect.minY + caretPosition
            case .insetFromEnd:
                y = rect.maxY - caretPosition
            }
            return CGPoint(x: rect.maxX, y: y)
            
        case .bottom:
            let x: CGFloat
            switch caretPositionType {
            case .normalized:
                let positionFactor = max(0, min(1, caretPosition))
                x = rect.minX + rect.width * positionFactor
            case .insetFromStart:
                x = rect.minX + caretPosition
            case .insetFromEnd:
                x = rect.maxX - caretPosition
            }
            return CGPoint(x: x, y: rect.maxY)
            
        case .left:
            let y: CGFloat
            switch caretPositionType {
            case .normalized:
                let positionFactor = max(0, min(1, caretPosition))
                y = rect.minY + rect.height * positionFactor
            case .insetFromStart:
                y = rect.minY + caretPosition
            case .insetFromEnd:
                y = rect.maxY - caretPosition
            }
            return CGPoint(x: rect.minX, y: y)
        }
    }
    
    private func calculateCaretPoints(in rect: CGRect) -> (start: CGPoint, tip: CGPoint, end: CGPoint)? {
        let safeDistanceFromCorner = cornerRadius * 1.5
        let halfCaretWidth = caretWidth / 2
        
        let baseCenter = getCaretBaseCenter(in: rect)
        
        switch edge {
        case .top:
            if baseCenter.x < rect.minX + safeDistanceFromCorner || baseCenter.x > rect.maxX - safeDistanceFromCorner {
                return nil
            }
        case .right:
            if baseCenter.y < rect.minY + safeDistanceFromCorner || baseCenter.y > rect.maxY - safeDistanceFromCorner {
                return nil
            }
        case .bottom:
            if baseCenter.x < rect.minX + safeDistanceFromCorner || baseCenter.x > rect.maxX - safeDistanceFromCorner {
                return nil
            }
        case .left:
            if baseCenter.y < rect.minY + safeDistanceFromCorner || baseCenter.y > rect.maxY - safeDistanceFromCorner {
                return nil
            }
        }
        
        return caretPoints(baseCenter: baseCenter, edge: edge, halfWidth: halfCaretWidth, height: caretHeight)
    }
    
    private func caretPoints(
        baseCenter: CGPoint,
        edge: CaretEdge,
        halfWidth: CGFloat,
        height: CGFloat
    ) -> (start: CGPoint, tip: CGPoint, end: CGPoint) {
        switch edge {
        case .top:
            let start = CGPoint(x: baseCenter.x - halfWidth, y: baseCenter.y)
            let tip = CGPoint(x: baseCenter.x, y: baseCenter.y - height)
            let end = CGPoint(x: baseCenter.x + halfWidth, y: baseCenter.y)
            return (start, tip, end)
            
        case .right:
            let start = CGPoint(x: baseCenter.x, y: baseCenter.y - halfWidth)
            let tip = CGPoint(x: baseCenter.x + height, y: baseCenter.y)
            let end = CGPoint(x: baseCenter.x, y: baseCenter.y + halfWidth)
            return (start, tip, end)
            
        case .bottom:
            let start = CGPoint(x: baseCenter.x + halfWidth, y: baseCenter.y)
            let tip = CGPoint(x: baseCenter.x, y: baseCenter.y + height)
            let end = CGPoint(x: baseCenter.x - halfWidth, y: baseCenter.y)
            return (start, tip, end)
            
        case .left:
            let start = CGPoint(x: baseCenter.x, y: baseCenter.y + halfWidth)
            let tip = CGPoint(x: baseCenter.x - height, y: baseCenter.y)
            let end = CGPoint(x: baseCenter.x, y: baseCenter.y - halfWidth)
            return (start, tip, end)
        }
    }
    
    private func drawRoundedTip(
        path: inout Path,
        from start: CGPoint,
        through tip: CGPoint,
        to end: CGPoint,
        radius: CGFloat
    ) {
        let dx1 = tip.x - start.x
        let dy1 = tip.y - start.y
        let angle1 = atan2(dy1, dx1)
        
        let dx2 = tip.x - end.x
        let dy2 = tip.y - end.y
        let angle2 = atan2(dy2, dx2)
        
        let distanceFromTip = radius
        
        let roundingStart = CGPoint(
            x: tip.x - distanceFromTip * cos(angle1),
            y: tip.y - distanceFromTip * sin(angle1)
        )
        
        let roundingEnd = CGPoint(
            x: tip.x - distanceFromTip * cos(angle2),
            y: tip.y - distanceFromTip * sin(angle2)
        )
        
        path.addLine(to: roundingStart)
        path.addQuadCurve(to: roundingEnd, control: tip)
        path.addLine(to: end)
    }

    public init(
        cornerRadius: CGFloat,
        caretSize: CGFloat,
        caretCornerRadius: CGFloat,
        caretPosition: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretSize
        self.caretHeight = caretSize
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretPosition
        self.caretPositionType = .normalized
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    public init(
        cornerRadius: CGFloat,
        caretWidth: CGFloat,
        caretHeight: CGFloat,
        caretCornerRadius: CGFloat,
        caretPosition: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretWidth
        self.caretHeight = caretHeight
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretPosition
        self.caretPositionType = .normalized
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    public init(
        cornerRadius: CGFloat,
        caretWidth: CGFloat,
        caretHeight: CGFloat,
        caretCornerRadius: CGFloat,
        caretInset: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretWidth
        self.caretHeight = caretHeight
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretInset
        self.caretPositionType = .insetFromStart
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    public init(
        cornerRadius: CGFloat,
        caretSize: CGFloat,
        caretCornerRadius: CGFloat,
        caretInset: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretSize
        self.caretHeight = caretSize
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretInset
        self.caretPositionType = .insetFromStart
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    public init(
        cornerRadius: CGFloat,
        caretWidth: CGFloat,
        caretHeight: CGFloat,
        caretCornerRadius: CGFloat,
        caretInsetFromEnd: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretWidth
        self.caretHeight = caretHeight
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretInsetFromEnd
        self.caretPositionType = .insetFromEnd
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    public init(
        cornerRadius: CGFloat,
        caretSize: CGFloat,
        caretCornerRadius: CGFloat,
        caretInsetFromEnd: CGFloat,
        edge: CaretEdge,
        caretAngle: Angle = .degrees(0)
    ) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretSize
        self.caretHeight = caretSize
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretInsetFromEnd
        self.caretPositionType = .insetFromEnd
        self.edge = edge
        self.caretAngle = caretAngle
    }
}

extension iBubble: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        var insetShape = self
        insetShape.insetAmount = amount
        return insetShape
    }
}

#Preview {
    VStack(spacing: 20) {
        iBubble(
            cornerRadius: 16,
            caretSize: 24,
            caretCornerRadius: 6,
            caretPosition: 0.5,
            edge: .top
        )
        .fill(Color.blue)
        .frame(width: 300, height: 150)
        .overlay(Text("Normalized: 0.5").foregroundColor(.white))
        
        iBubble(
            cornerRadius: 16,
            caretWidth: 24,
            caretHeight: 12,
            caretCornerRadius: 6,
            caretInset: 50,
            edge: .bottom
        )
        .fill(Color.green)
        .frame(width: 300, height: 150)
        .overlay(Text("Inset from left: 50px").foregroundColor(.white))
        
        iBubble(
            cornerRadius: 16,
            caretSize: 24,
            caretCornerRadius: 6,
            caretInsetFromEnd: 50,
            edge: .bottom
        )
        .fill(Color.orange)
        .frame(width: 300, height: 150)
        .overlay(Text("Inset from right: 50px").foregroundColor(.white))
        
        HStack(spacing: 20) {
            iBubble(
                cornerRadius: 16,
                caretSize: 24,
                caretCornerRadius: 6,
                caretInset: 30,
                edge: .left
            )
            .fill(Color.purple)
            .frame(width: 140, height: 150)
            .overlay(Text("From top: 30px").foregroundColor(.white))
            
            iBubble(
                cornerRadius: 16,
                caretSize: 24,
                caretCornerRadius: 6,
                caretInsetFromEnd: 30,
                edge: .right
            )
            .fill(Color.red)
            .frame(width: 140, height: 150)
            .overlay(Text("From bottom: 30px").foregroundColor(.white))
        }
    }
    .padding()
}
