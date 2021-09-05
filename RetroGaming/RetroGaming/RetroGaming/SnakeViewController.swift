import UIKit
import SnakeGame

class SnakeViewController: UIViewController {

    @IBOutlet weak var snakeView: SnakeView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!

    private var snake: SnakeModel?
    private var fruit: Point?
    private var timer: Timer?
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    private var shapeLayer: CAShapeLayer? {
        didSet {
            guard let shapeLayer = shapeLayer else {
                return
            }

            guard let oldValue = oldValue else {
                snakeView.layer.addSublayer(shapeLayer)
                return
            }
            
            snakeView.layer.replaceSublayer(oldValue, with: shapeLayer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        snake = SnakeModel(worldSize: WorldSize(width: 20, height: 20))
        snakeView.delegate = self

        configure(button: playButton)

        let directionArray: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        directionArray.forEach { direction in
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        shapeLayer = createCells()
    }

    private func configure(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
    }

    private func createFruit() {
        guard let snake = snake else { return }

        let width = UInt32(snake.worldSize.width)
        let height = UInt32(snake.worldSize.height)


        while true {
            var isBody = false
            let x = arc4random_uniform(width)
            let y = arc4random_uniform(height)

            for point in snake.body {
                if point.x == CGFloat(x) && point.y == CGFloat(y) {
                    isBody = true
                    break
                }
            }

            if !isBody {
                fruit = Point(x: CGFloat(x), y: CGFloat(y))
                break
            }
        }
    }

    private func createCells() -> CAShapeLayer {
        let path = UIBezierPath()
        let delta = snakeView.frame.width / 20

        for i in 1..<20 {
            path.move(to: CGPoint(x: 0.0, y: delta * CGFloat(i)))
            path.addLine(to: CGPoint(x: snakeView.frame.width, y: delta * CGFloat(i)))
        }

        for i in 1..<20 {
            path.move(to: CGPoint(x: delta * CGFloat(i), y: 0.0))
            path.addLine(to: CGPoint(x: delta * CGFloat(i), y: snakeView.frame.height))
        }

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 0.271, green: 0.271, blue: 0.271, alpha: 1.0).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1

        return shapeLayer
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        (sender as? UIButton)?.isEnabled = false

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.playButton.alpha = 0.5
        })
        score = 0

        self.snake = SnakeModel(worldSize: WorldSize(width: 20, height: 20))
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.timerAction(_:)) , userInfo: nil, repeats: true)
        self.snakeView.setNeedsDisplay()
        self.timer?.fire()
        self.createFruit()
    }

    @objc private func timerAction(_ sender: AnyObject) {
        guard let fruit = fruit else { return }
        guard let snake = snake else { return }

        snake.moveHead()
        if snake.head.x == fruit.x && snake.head.y == fruit.y {
            snake.extendBody()
            score += 1

            createFruit()
        }

        if snake.bumpIntoBorder() || snake.bumpIntoSelf() {
            timer?.invalidate()
            timer = nil

            snake.extendBody()

            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.playButton.alpha = 1
            })
            playButton.isEnabled = true
            scoreLabel.text = "Game Over!"
        }
        snakeView.setNeedsDisplay()
    }

    @objc private func swipeAction(_ sender: UIGestureRecognizer) {
        guard let gesture = sender as? UISwipeGestureRecognizer else { return }

        switch gesture.direction {
            case UISwipeGestureRecognizer.Direction.up:
            snake?.direction = .Down
            case UISwipeGestureRecognizer.Direction.down:
            snake?.direction = .Up
            case UISwipeGestureRecognizer.Direction.left:
            snake?.direction = .Left
            case UISwipeGestureRecognizer.Direction.right:
            snake?.direction = .Right

        default: break
        }
    }
}

extension SnakeViewController: SnakeViewDelegate {
    func snakeModelForSnakeView(_ view: SnakeView) -> SnakeModel {
        return snake!
    }

    func pointOfFruitForSnakeView(_ view: SnakeView) -> Point? {
        return fruit
    }
}

