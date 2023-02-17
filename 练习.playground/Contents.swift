//: A UIKit based Playground for presenting user interface
import Foundation

struct Point {
    var x: Double
    var y: Double
    
    
    // 运算符重载
    static func + (p1: Point, p2: Point) -> Point {
        return Point(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    
    
    //swift 下标
    subscript(index: Int) -> Double {
        set {
            if index == 0 {
                x = newValue
            } else {
                y = newValue
            }
        }
        get {
            if index == 0 {
                return x
            }
            if index == 1 {
                return y
            }
            return 0
        }
    }
    
}

let p1 = Point(x: 5.2, y: 5.5)
let p2 = Point(x: 8, y: 8)

//print("\(p1+p2)")

//
print("\(p1.x)")
