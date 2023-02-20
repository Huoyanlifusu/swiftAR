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
        set(newValue) {
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

//var p1 = Point(x: 5.2, y: 5.5)
//let p2 = Point(x: 8, y: 8)
//p1[0] = 1
//p1[1] = 2
//print(p1)



//swift 协议
protocol fullName {
    var name: String { get }
}

struct Person: fullName {
    var name: String
}
//let john = Person(name: "John")
//print(john)

protocol RandomNumberGenerator {
    func randow() -> Double
}

class LinerRandom: RandomNumberGenerator {
    func randow() -> Double {
        return 0
    }
}
//mutating 关键字
protocol toggleable {
    mutating func changeState()
}

enum Switch: toggleable {
    case on, off
    mutating func changeState() {
        switch self {
        case .on:
            self = .off
            return
        case .off:
            self = .on
            return
        }
    }
}

//var lightSwitch = Switch.off
//lightSwitch.changeState()
//print(lightSwitch)


//GCD
let item1 = DispatchWorkItem {
    for i in 0...4{
        print("item1 -> \(i)  thread: \(Thread.current)")
    }
}

let item2 = DispatchWorkItem {
    for i in 0...4{
        print("item2 -> \(i)  thread: \(Thread.current)")
    }
}

let item3 = DispatchWorkItem {
    for i in 0...4{
        print("item3 -> \(i)  thread: \(Thread.current)")
    }
}

let item4 = DispatchWorkItem {
    for i in 0...4{
        print("item4 -> \(i)  thread: \(Thread.current)")
    }
}
//串行异步
//let mainQueue = DispatchQueue.main
//mainQueue.async(execute: item1)
//mainQueue.async(execute: item2)
//mainQueue.async(execute: item3)
//mainQueue.async(execute: item4)
//并行异步
//let globalQueue = DispatchQueue.global()
//globalQueue.async(execute: item1)
//globalQueue.async(execute: item2)
//globalQueue.async(execute: item3)
//globalQueue.async(execute: item4)
//串行异步
//let serialQueue = DispatchQueue(label: "serial")
//serialQueue.async(execute: item1)
//serialQueue.async(execute: item2)
//serialQueue.async(execute: item3)
//serialQueue.async(execute: item4)
//并行异步
//let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//concurrentQueue.async(execute: item1)
//concurrentQueue.async(execute: item2)
//concurrentQueue.async(execute: item3)
//concurrentQueue.async(execute: item4)
//主队列+同步任务 死锁
//let mainQueue = DispatchQueue.main
//mainQueue.sync(execute: item1)
//mainQueue.sync(execute: item2)
//mainQueue.sync(execute: item3)
//mainQueue.sync(execute: item4)
//全球队列并行同步 按顺序执行
//let globalQueue = DispatchQueue.global()
//globalQueue.sync(execute: item1)
//globalQueue.sync(execute: item2)
//globalQueue.sync(execute: item3)
//globalQueue.sync(execute: item4)
//自定义队列串行同步 按顺序打印
//let serialQueue = DispatchQueue(label: "serial")
//serialQueue.sync(execute: item1)
//serialQueue.sync(execute: item2)
//serialQueue.sync(execute: item3)
//serialQueue.sync(execute: item4)
//自定义队列并行同步 按顺序打印
//let concureentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//concureentQueue.sync(execute: item1)
//concureentQueue.sync(execute: item2)
//concureentQueue.sync(execute: item3)
//concureentQueue.sync(execute: item4)

//swift 多态
class Animal {
    func speak() {
        print("Animal speak")
    }
    func eat() {
        print("Animal eat")
    }
    func sleep() {
        print("Animal sleep")
    }
}

class Dog : Animal {
    override func speak() {
        print("Dog speak")
    }
    override func eat() {
        print("Dog eat")
    }
    func run() {
        print("Dog run")
    }
}

var anim = Animal() //父类指针
anim = Dog() //指向子类对象

//这时候，编译器提示，anim是Animal类型的，但是实际是Dog类型的
anim.speak()
anim.eat()
anim.sleep()
