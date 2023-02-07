//
//  Pie.swift
//  memory
//
//  Created by 张裕阳 on 2022/8/20.
//

import SwiftUI

struct Pie: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockWise: Bool = false
    func path(in rect: CGRect) -> Path {
        
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let start = CGPoint(
            x: centerPoint.x + radius * CGFloat(cos(startAngle.radians)),
            y: centerPoint.y + radius * CGFloat(sin(startAngle.radians))
        )
        
        var p = Path()
        p.move(to: centerPoint)
        p.addLine(to: start)
        p.addArc(center: centerPoint,
                 radius: radius,
                 startAngle: startAngle,
                 endAngle: endAngle,
                 clockwise: !clockWise
        )
        p.addLine(to: centerPoint)
        return p
    }
    
}
