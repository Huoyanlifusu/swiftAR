//: A UIKit based Playground for presenting user interface
import Foundation

//struct Point {
//    var x: Double
//    var y: Double
//
//
//    // 运算符重载
//    static func + (p1: Point, p2: Point) -> Point {
//        return Point(x: p1.x + p2.x, y: p1.y + p2.y)
//    }
//
//
//    //swift 下标
//    subscript(index: Int) -> Double {
//        set(newValue) {
//            if index == 0 {
//                x = newValue
//            } else {
//                y = newValue
//            }
//        }
//        get {
//            if index == 0 {
//                return x
//            }
//            if index == 1 {
//                return y
//            }
//            return 0
//        }
//    }
//
//}

//var p1 = Point(x: 5.2, y: 5.5)
//let p2 = Point(x: 8, y: 8)
//p1[0] = 1
//p1[1] = 2
//print(p1)



//swift 协议
protocol fullName {
    var name: String { get }
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
//class Animal {
//    func speak() {
//        print("Animal speak")
//    }
//    func eat() {
//        print("Animal eat")
//    }
//    func sleep() {
//        print("Animal sleep")
//    }
//}
//
//class Dog : Animal {
//    override func speak() {
//        print("Dog speak")
//    }
//    override func eat() {
//        print("Dog eat")
//    }
//    func run() {
//        print("Dog run")
//    }
//}
//
//var anim = Animal() //父类指针
//anim = Dog() //指向子类对象

//这时候，编译器提示，anim是Animal类型的，但是实际是Dog类型的
//anim.speak()
//anim.eat()
//anim.sleep()


//map, reduce, filter 高阶函数

//struct Person {
//    let name: String
//    let money: String
//}
//
//let a = Person(name: "Joe", money: "20")
//let b = Person(name: "Mike", money: "30")
//let c = Person(name: "Krystel", money: "220")
//
////对数组每个元素按顺序执行reduce，前一个结果作为参数汇入
//let sumMoney = [a, b, c].reduce(0) {
//    return $0 + ($1.money as NSString).doubleValue
//}
////
//
//struct Student {
//    let id: String
//    let name: String
//    let age: Int
//}
//
//let stu1 = Student(id: "1001", name: "stu1", age: 12)
//let stu2 = Student(id: "1002", name: "stu2", age: 14)
//let stu3 = Student(id: "1003", name: "stu3", age: 16)
//let stu4 = Student(id: "1004", name: "stu4", age: 20)
//let stus = [stu1, stu2, stu3, stu4]
//
//let intIds = stus.map { (stu) in
//    Int(stu.id)
//}
//
//print(intIds)


//设计模式
//组合模式
//
//protocol File {
//    var name: String { get set }
//    func open()
//}
//
//final class eBook: File {
//    var name: String
//    var author: String
//
//    init(name: String, author: String) {
//        self.name = name
//        self.author = author
//    }
//
//    func open() {
//        print(author + " write a book called " + name)
//    }
//}
//
//final class Music: File {
//    var name: String
//    var artist: String
//
//    init(name: String, artist: String) {
//        self.name = name
//        self.artist = artist
//    }
//    func open() {
//        print(artist + " write a song called " + name)
//    }
//}
//
//final class Folder: File {
//    var name: String
//    lazy var files: [File] = []
//
//    init(name: String) {
//        self.name = name
//    }
//
//    func addFile(file: File) {
//        self.files.append(file)
//    }
//
//    func open() {
//        print(name + "has files: ")
//        files.forEach { (file) in
//            print(file.name)
//            file.open()
//        }
//        print("\n")
//    }
//}
//
//
//let psychoKiller = Music(name: "Psycho Killer", artist: "The Talking Heads")
//let rebelRebel = Music(name: "Reble Rebel", artist: "David Bowie")
//let blisterInTheSun = Music(name: "Blister in the Sun", artist: "Violent Femmes")
//
//let justKids = eBook(name: "Just Kids", author: "Patti Smith")
//
//let documents = Folder(name: "Documents")
//
//let musicFolder = Folder(name: "最喜欢的70首音乐")
//
//documents.addFile(file: musicFolder)
//musicFolder.addFile(file: psychoKiller)
//musicFolder.addFile(file: rebelRebel)
//musicFolder.addFile(file: blisterInTheSun)
//
////设计模式 装饰模式
//protocol Shape {
//    func draw()
//}
//
//class Rectangle: Shape {
//    func draw() {
//        print("矩形")
//    }
//}
//
//class Circle: Shape {
//    func draw() {
//        print("圆形")
//    }
//}
//
//class ShapeDecorator: Shape {
//    let decoratedShape: Shape
//
//    init(shape: Shape) {
//        decoratedShape = shape
//    }
//
//    func draw() {
//        decoratedShape.draw()
//    }
//}
//
//class RedShapeDecoratoe: ShapeDecorator {
//    override func draw() {
//        super.draw()
//        setRedBorder()
//    }
//
//    func setRedBorder() {
//        print("红色边框")
//    }
//}
//
//let circle = Circle()
//let redCircle = RedShapeDecoratoe(shape: circle)
//let redRectangle = RedShapeDecoratoe(shape: Rectangle())
//
////circle.draw()
////print("------")
////redCircle.draw()
////print("------")
////redRectangle.draw()
//
////设计模式 外观模式
//class Facade {
//    let one = SubSystemOne()
//    let two = SubSystemTwo()
//    let three = SubSystemThree()
//    let four = SubSystemFour()
//
//    public func methodA() {
//        one.methodOne()
//        two.methodTwo()
//        three.methodThree()
//        print("A")
//    }
//
//    public func methodB() {
//        two.methodTwo()
//        three.methodThree()
//        four.methodFoure()
//        print("B")
//    }
//
//}
//
//class SubSystemOne {
//    public func methodOne() {
//        print("子系统方法一")
//    }
//}
//
//class SubSystemTwo {
//    public func methodTwo() {
//        print("子系统方法二")
//    }
//}
//
//class SubSystemThree {
//    public func methodThree() {
//        print("子系统方法三")
//    }
//}
//
//class SubSystemFour {
//    public func methodFoure() {
//        print("子系统方法四")
//    }
//}
//
//let facade = Facade()
//facade.methodA()
//print("------")
//facade.methodB()

//swift 单例模式 全局变量写法
//class TheOneAndOnlyKraken {
//    class var sharedInstance: TheOneAndOnlyKraken {
//        return sharedInstance
//    }
//}
//
//private let sharedKraken = TheOneAndOnlyKraken()

//正确的单例写法
//class TheOneAndOnly {
//    static let sharedInstance = TheOneAndOnly()
//}
//
//private let shared = TheOneAndOnly()

//func swap(a: inout Int, b: inout Int) {
//    (a, b) = (b, a)
//}
//swap函数和min函数
//func swap<T>(nums: inout [T], p: Int, q: Int) {
//    (nums[p], nums[q]) = (nums[q], nums[p])
//}
//
//func min<T : Comparable>(_ a: T, b: T) -> T {
//    return a < b ? a : b
//}
//
//
//var nums = [0,5,6,102,66,44,290,9]
//swap(nums: &nums, p: 0, q: 1)
//协议类型别名
//typealias SomeClosureType = (String) -> (Void)
//let someClosure: SomeClosureType = { (name: String) in
//    print("hello ", name)
//}

//someClosure("world")


//闭包部分 尾随闭包
//func exec(v1: Int, v2: Int, fn: (Int, Int) -> Int) {
//    print(fn(v1, v2))
//}

//exec(v1: 2, v2: 5) {
//    $0 + $1
//}


let filemgr = FileManager.default
let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)

let myDocumentDirectory = dirPaths[0]
let projDir = myDocumentDirectory.appendingPathComponent("helloworld")
let metaFile = projDir.appendingPathComponent("metadata.json")
print("\(projDir)")


public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init(_ val: Int = 0, _ next: ListNode? = nil) {
        self.val = val
        self.next = next
    }
}


//反向打印链表
public class Solution {
    func printListFromTailToHead ( _ head: ListNode?) -> [Int] {
        var list: Array<Int> = []
        // write code here
        if head?.next != nil {
            return printListFromTailToHead(head?.next) + list
        }
        guard let val = head?.val else { fatalError() }
        return [val] + list
    }
}
//链表反转
func ReverseList ( _ head: ListNode?) -> ListNode? {
        // write code here
        if head?.next?.next != nil {
            ReverseList(head?.next)
        }
        head?.next?.next = head
        return head?.next
}

//字典创建
var nameDic: [String: Int] = ["pes":1]
if nameDic["pes"] == 1 {
    print("1")
}


