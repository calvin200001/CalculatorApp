import UIKit

class ViewController: UIViewController {
    
    private let calculator = Calculator()
    private var currentNumber: String = "0"
    
    private let displayLabel = UILabel()
    private let buttonContainer = UIView()
    
    private let buttons = [
        ["C", "⌫", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    private let operatorColor = UIColor(red: 100/255, green: 132/255, blue: 180/255, alpha: 1.0)
    private let clearColor = UIColor(red: 210/255, green: 190/255, blue: 165/255, alpha: 1.0)
    private let numberColor = UIColor(red: 75/255, green: 85/255, blue: 95/255, alpha: 1.0)
    private let equalColor = UIColor(red: 120/255, green: 150/255, blue: 190/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }
    
    private func setupUI() {
        // Display setup
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.font = .systemFont(ofSize: 70, weight: .light)
        displayLabel.textAlignment = .right
        displayLabel.text = currentNumber
        displayLabel.textColor = .white
        displayLabel.adjustsFontSizeToFitWidth = true
        displayLabel.minimumScaleFactor = 0.5
        view.addSubview(displayLabel)
        
        // Button container
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonContainer)
        
        NSLayoutConstraint.activate([
            displayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            displayLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            displayLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            displayLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            buttonContainer.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 20),
            buttonContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            buttonContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Remove all existing constraints and buttons
        for subview in buttonContainer.subviews {
            subview.removeFromSuperview()
        }
        
        let buttonGap: CGFloat = 10
        let rows = buttons.count
        let cols = 4 // Maximum columns in any row
        
        let containerWidth = buttonContainer.frame.width
        let containerHeight = buttonContainer.frame.height
        
        let buttonWidth = (containerWidth - (CGFloat(cols - 1) * buttonGap)) / CGFloat(cols)
        let buttonHeight = (containerHeight - (CGFloat(rows - 1) * buttonGap)) / CGFloat(rows)
        
        for row in 0..<buttons.count {
            for col in 0..<buttons[row].count {
                let buttonTitle = buttons[row][col]
                let button = UIButton()
                button.setTitle(buttonTitle, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 30, weight: .medium)
                button.setTitleColor(.white, for: .normal)
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                button.layer.cornerRadius = 12
                
                // Set button color based on function
                if buttonTitle == "C" {
                    button.backgroundColor = clearColor
                } else if ["÷", "×", "-", "+", "%"].contains(buttonTitle) {
                    button.backgroundColor = operatorColor
                } else if buttonTitle == "=" {
                    button.backgroundColor = equalColor
                } else {
                    button.backgroundColor = numberColor
                }
                
                buttonContainer.addSubview(button)
                
                // Position the button
                var width = buttonWidth
                var xOffset = CGFloat(col) * (buttonWidth + buttonGap)
                
                // Special case for the zero button (wider)
                if row == 4 && col == 0 {
                    width = buttonWidth * 2 + buttonGap
                }
                
                // Last row adjustments
                if row == 4 {
                    if col == 1 {
                        xOffset = 2 * (buttonWidth + buttonGap)
                    } else if col == 2 {
                        xOffset = 3 * (buttonWidth + buttonGap)
                    }
                }
                
                button.frame = CGRect(
                    x: xOffset,
                    y: CGFloat(row) * (buttonHeight + buttonGap),
                    width: width,
                    height: buttonHeight
                )
            }
        }
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        let title = sender.titleLabel?.text ?? ""
        
        // Add button tap animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
                sender.alpha = 1.0
            }
        }
        
        switch title {
        case "C":
            clearDisplay()
        case "=":
            calculateResult()
        case "⌫":
            deleteLastCharacter()
        case "+", "-", "×", "÷":
            storeOperation(title)
        case "%":
            calculatePercentage()
        default:
            appendNumber(title)
        }
    }
    
    private func clearDisplay() {
        currentNumber = "0"
        calculator.clear()
        displayLabel.text = currentNumber
    }
    
    private func appendNumber(_ number: String) {
        if currentNumber == "0" {
            currentNumber = number
        } else {
            currentNumber += number
        }
        displayLabel.text = currentNumber
    }
    
    private func storeOperation(_ op: String) {
        guard let number = Double(currentNumber) else { return }
        calculator.appendNumber(number)
        switch op {
        case "+":
            calculator.storeOperation(.add)
        case "-":
            calculator.storeOperation(.subtract)
        case "×":
            calculator.storeOperation(.multiply)
        case "÷":
            calculator.storeOperation(.divide)
        default:
            return
        }
        currentNumber = "0"
        displayLabel.text = currentNumber
    }
    
    private func calculateResult() {
        guard let number = Double(currentNumber) else { return }
        calculator.appendNumber(number)
        guard let result = calculator.calculate() else {
            clearDisplay()
            return
        }
        
        // Format the result to remove trailing zeros
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            currentNumber = String(format: "%.0f", result)
        } else {
            currentNumber = String(result)
        }
        
        displayLabel.text = currentNumber
    }
    
    private func deleteLastCharacter() {
        currentNumber = String(currentNumber.dropLast())
        if currentNumber.isEmpty {
            currentNumber = "0"
        }
        displayLabel.text = currentNumber
    }
    
    private func calculatePercentage() {
        if let number = Double(currentNumber) {
            let result = number / 100.0
            currentNumber = String(result)
            displayLabel.text = currentNumber
        }
    }
}