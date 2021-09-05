import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tetrisButton: UIButton!
    @IBOutlet weak var snakeButton: UIButton!
    @IBOutlet weak var titleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(button: tetrisButton)
        configure(button: snakeButton)
        titleView.layer.cornerRadius = 10
        titleView.layer.shadowColor = UIColor.black.cgColor
        titleView.layer.shadowOpacity = 0.5
        titleView.layer.shadowOffset = .zero
        titleView.layer.shadowRadius = 5
    }

    private func configure(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
    }

    @IBAction func openTetris(_ sender: Any) {
        performSegue(withIdentifier: "openTetrisSegue", sender: nil)
    }

    @IBAction func openSnake(_ sender: Any) {
        performSegue(withIdentifier: "openSnakeSegue", sender: nil)
    }


}

