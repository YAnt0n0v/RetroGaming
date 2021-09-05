import UIKit

public protocol SnakeViewDelegate {
    func snakeModelForSnakeView(_ view: SnakeView) -> SnakeModel
    func pointOfFruitForSnakeView(_ view:SnakeView) -> Point?
}

@IBDesignable
public class SnakeView: UIView {

    public var delegate: SnakeViewDelegate?

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let snake = delegate?.snakeModelForSnakeView(self) else { return }


        let worldSize = snake.worldSize

        let w = rect.width / CGFloat(worldSize.width)
        let h = rect.height / CGFloat(worldSize.height)

        UIColor(red: 0.595, green: 1.0, blue: 0.579, alpha: 1).set()
        for point in snake.body {
            let rect = CGRect(x: point.x * w, y: point.y * h, width: w, height: h)
            UIBezierPath(rect: rect).fill()
        }


        if let fruit = delegate?.pointOfFruitForSnakeView(self) {
            UIColor(red: 1.0, green: 0.422, blue: 0.398, alpha: 1).set()
            let rect = CGRect(x: fruit.x * w, y: fruit.y * h, width: w, height: h)
            UIBezierPath(rect: rect).fill()
        }
    }

}
