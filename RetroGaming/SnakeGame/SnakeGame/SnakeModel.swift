import Foundation
import UIKit

public struct WorldSize {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public struct Point {
    public let x: CGFloat
    public let y: CGFloat

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

public enum Direction {
    case Up
    case Down
    case Right
    case Left

    public func shouldChangeDirection(_ direction: Direction) -> Bool {
        var canChange = true

        switch self {
        case .Right, .Left:
            canChange = direction == .Up || direction == .Down
        case .Up, .Down:
            canChange = direction == .Right || direction == .Left
        }
        return canChange
    }
}

public class SnakeModel {

    private var _cachedTail: Point?
    private var _direction: Direction = .Right

    private(set) public var worldSize: WorldSize

    public var body: [Point] = []
    public var head: Point! {
        return body.first
    }
    public var direction: Direction {
        get {
            return _direction
        }
        set (newDirection) {
            if _direction.shouldChangeDirection(newDirection) {
                _direction = newDirection
            }
        }
    }

    public init(worldSize: WorldSize) {
        guard worldSize.width >= 5 && worldSize.height >= 5 else {
            fatalError("worldSize should be (width, height) >= (5, 5)")
        }
        self.worldSize = worldSize

        for i in 0..<2 {
            body.append(Point(x: CGFloat(worldSize.width / 2 - i), y: CGFloat(worldSize.height / 2)))
        }
    }


    private func _willMoveHead() -> Point {
        var newHead: Point!

        switch direction {
        case .Up:
            newHead = Point(x: head.x, y: head.y + 1)
        case .Down:
            newHead = Point(x: head.x, y: head.y - 1)
        case .Right:
            newHead = Point(x: head.x + 1, y: head.y)
        case .Left:
            newHead = Point(x: head.x - 1, y: head.y)
        }
        return newHead
    }

    private func _bump(intoPoint point: Point, byHead head: Point) -> Bool {
        return point.x == head.x && point.y == head.y
    }

    public func moveHead() {
        body.insert(_willMoveHead(), at: 0)
        _cachedTail = body.popLast()
    }

    public func extendBody() {
        if let tail = _cachedTail {
            body.append(tail)
        }
    }

    public func bumpIntoSelf() -> Bool {
        for (idx, point) in body.enumerated() {
            if idx == 0 { continue }

            if point.x == head.x && point.y == head.y {
                return true
            }
        }

        if let tail = _cachedTail {
            if tail.x == head.x && tail.y == head.y {
                return true
            }
        }

        return false
    }

    public func bumpIntoBorder() -> Bool {
        return head.x >= CGFloat(worldSize.width) || head.x < 0 || head.y >= CGFloat(worldSize.height) || head.y < 0
    }

}
