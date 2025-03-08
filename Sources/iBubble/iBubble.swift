//
//  iBubble.swift
//  iBubble
//
//  Created by Benjamin Sage on 3/8/25.
//

import SwiftUI

struct iBubble: Shape {
    enum CaretEdge { case top, right, bottom, left }

    var cornerRadius: CGFloat
    var caretWidth: CGFloat
    var caretHeight: CGFloat
    var caretCornerRadius: CGFloat
    var caretPosition: CGFloat
    var edge: CaretEdge
    var caretAngle: Angle = .degrees(0)
    
    func path(in rect: CGRect) -> Path {
        let basePath = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).path(in: rect)
        
        if let caretPath = createCaretPath(in: rect) {
            return Path { path in
                path.addPath(basePath)
                path.addPath(caretPath)
            }
        }
        
        return basePath
    }
    
    private func createCaretPath(in rect: CGRect) -> Path? {
        let positionFactor = max(0, min(1, caretPosition))
        
        let caretBaseCenter: CGPoint
        let safeDistanceFromCorner = cornerRadius * 1.5
        let halfCaretWidth = caretWidth / 2
        
        switch edge {
        case .top:
            caretBaseCenter = CGPoint(x: rect.minX + rect.width * positionFactor, y: rect.minY)
            if caretBaseCenter.x < rect.minX + safeDistanceFromCorner || caretBaseCenter.x > rect.maxX - safeDistanceFromCorner {
                return nil
            }
            
        case .right:
            caretBaseCenter = CGPoint(x: rect.maxX, y: rect.minY + rect.height * positionFactor)
            if caretBaseCenter.y < rect.minY + safeDistanceFromCorner || caretBaseCenter.y > rect.maxY - safeDistanceFromCorner {
                return nil
            }
            
        case .bottom:
            caretBaseCenter = CGPoint(x: rect.minX + rect.width * positionFactor, y: rect.maxY)
            if caretBaseCenter.x < rect.minX + safeDistanceFromCorner || caretBaseCenter.x > rect.maxX - safeDistanceFromCorner {
                return nil
            }
            
        case .left:
            caretBaseCenter = CGPoint(x: rect.minX, y: rect.minY + rect.height * positionFactor)
            if caretBaseCenter.y < rect.minY + safeDistanceFromCorner || caretBaseCenter.y > rect.maxY - safeDistanceFromCorner {
                return nil
            }
        }
        
        return Path { path in
            let (startPoint, tipPoint, endPoint) = caretPoints(baseCenter: caretBaseCenter, edge: edge, halfWidth: halfCaretWidth, height: caretHeight)
            
            path.move(to: startPoint)
            
            if caretCornerRadius > 0 {
                let tipRadius = min(caretCornerRadius, caretWidth/4, caretHeight/4)
                drawRoundedTip(
                    path: &path,
                    from: startPoint,
                    through: tipPoint,
                    to: endPoint,
                    radius: tipRadius
                )
            } else {
                path.addLine(to: tipPoint)
                path.addLine(to: endPoint)
            }
            
            path.closeSubpath()
        }
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

    init(cornerRadius: CGFloat, caretSize: CGFloat, caretCornerRadius: CGFloat, caretPosition: CGFloat, edge: CaretEdge, caretAngle: Angle = .degrees(0)) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretSize
        self.caretHeight = caretSize
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretPosition
        self.edge = edge
        self.caretAngle = caretAngle
    }
    
    init(cornerRadius: CGFloat, caretWidth: CGFloat, caretHeight: CGFloat, caretCornerRadius: CGFloat, caretPosition: CGFloat, edge: CaretEdge, caretAngle: Angle = .degrees(0)) {
        self.cornerRadius = cornerRadius
        self.caretWidth = caretWidth
        self.caretHeight = caretHeight
        self.caretCornerRadius = caretCornerRadius
        self.caretPosition = caretPosition
        self.edge = edge
        self.caretAngle = caretAngle
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
        
        iBubble(
            cornerRadius: 16,
            caretWidth: 24,
            caretHeight: 12,
            caretCornerRadius: 6,
            caretPosition: 0.2,
            edge: .right
        )
        .fill(Color.green)
        .frame(width: 300, height: 150)
        
        iBubble(
            cornerRadius: 16,
            caretSize: 24,
            caretCornerRadius: 6,
            caretPosition: 0.8,
            edge: .bottom
        )
        .fill(Color.orange)
        .frame(width: 300, height: 150)
        
        iBubble(
            cornerRadius: 16,
            caretSize: 24,
            caretCornerRadius: 6,
            caretPosition: 0.5,
            edge: .left
        )
        .fill(Color.purple)
        .frame(width: 300, height: 150)
    }
    .padding()
}
