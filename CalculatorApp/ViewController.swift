import UIKit

class ViewController: UIViewController {
    
    private let calculator = Calculator()
    private var currentNumber: String = "0"
    private var firstNumber: String?
    private var operation: Calculator.Operation?
    
    private let displayLabel = UILabel()
    private let buttons = [
        ["7", "8", "9", "÷", "C"],
        ["4", "5", "6", "×", "="],
        ["1", "2", "3", "-", "+"],
        ["0", ".", "=", "⌫", ""]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.font = .systemFont(ofSize: 48, weight: .bold)
        displayLabel.textAlignment = .right
        displayLabel.text = currentNumber
        view.addSubview(displayLabel)
        
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStackView)
        
        buttons.forEach { row in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 8
            rowStackView.distribution = .fillEqually
            row.forEach { item in
                let button = UIButton()
                button.setTitle(item, for: .normal)
                button.backgroundColor = .systemGray
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
            }
            buttonsStackView.addArrangedSubview(rowStackView)
        }
        
        NSLayoutConstraint.activate([
            displayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            displayLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            displayLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            displayLabel.heightAnchor.constraint(equalToConstant: 80),
            
            buttonsStackView.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        let title = sender.titleLabel?.text ?? ""
        switch title {
        case "C":
            clearDisplay()
        case "=":
            calculateResult()
        case "⌫":
            deleteLastCharacter()
        case "+", "-", "×", "÷":
            storeOperation(title)
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
        currentNumber = String(result)
        displayLabel.text = currentNumber
    }
    
    private func deleteLastCharacter() {
        currentNumber = String(currentNumber.dropLast())
        if currentNumber.isEmpty {
            currentNumber = "0"
        }
        displayLabel.text = currentNumber
    }
}