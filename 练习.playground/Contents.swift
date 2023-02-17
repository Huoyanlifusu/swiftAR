//: A UIKit based Playground for presenting user interface
import Foundation

// 运算符重载
struct Point {
    var x: Int
    var y: Int
    
    static func + (p1: Point, p2: Point) -> Point {
        return Point(x: p1.x + p2.x, y: p1.y + p2.y)
    }
}

let p1 = Point(x: 5, y: 5)
let p2 = Point(x: 8, y: 8)

print("\(p1+p2)")

//
