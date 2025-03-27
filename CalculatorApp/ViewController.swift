// Refactored content for ViewController.swift
import UIKit
import CoreData

class ViewController: UIViewController {

    // --- Constants for Colors (As before) ---
    private struct Colors {
        static let background = UIColor.black
        static let display = UIColor.white
        static let clearButtonBackground = UIColor(red: 0.85, green: 0.78, blue: 0.70, alpha: 1.0)
        static let clearButtonText = UIColor.black
        static let numberButtonBackground = UIColor(white: 0.25, alpha: 1.0)
        static let numberButtonText = UIColor.white
        static let functionButtonBackground = UIColor(white: 0.25, alpha: 1.0)
        static let functionButtonText = UIColor.white
        static let operatorButtonBackground = UIColor(red: 0.25, green: 0.50, blue: 0.80, alpha: 1.0) // Blue
        static let operatorButtonText = UIColor.white
        static let historyButtonTint = UIColor(red: 0.25, green: 0.50, blue: 0.80, alpha: 1.0) // Blue
        // --- Added Color for Operator Highlight ---
        static let operatorHighlightBorder = UIColor.white.withAlphaComponent(0.8).cgColor // White border for highlight
    }

    // --- UI Properties ---
    private let display: UILabel = { /* ... as before ... */
        let element = UILabel()
        element.text = "0"
        element.textAlignment = .right
        element.font = UIFont.systemFont(ofSize: 80, weight: .light)
        element.textColor = Colors.display
        element.adjustsFontSizeToFitWidth = true
        element.minimumScaleFactor = 0.5
        return element
    }()

    // --- Button Properties ---
    private lazy var numberButtons: [UIButton] = createNumberButtons()
    private lazy var operatorButtons: [UIButton] = createOperatorButtons()
    private lazy var clearButton: UIButton = createStyledButton(title: "C", backgroundColor: Colors.clearButtonBackground, titleColor: Colors.clearButtonText, action: #selector(clearButtonTapped))
    private lazy var deleteButton: UIButton = createStyledButton(title: "⌫", backgroundColor: Colors.functionButtonBackground, titleColor: Colors.functionButtonText, action: #selector(deleteButtonTapped))
    private lazy var percentButton: UIButton = createStyledButton(title: "%", backgroundColor: Colors.functionButtonBackground, titleColor: Colors.functionButtonText, action: #selector(percentButtonTapped))
    private lazy var equalsButton: UIButton = createStyledButton(title: "=", backgroundColor: Colors.operatorButtonBackground, titleColor: Colors.operatorButtonText, action: #selector(equalsButtonTapped))

    // --- Data Properties ---
    private let service: CalculatorService
    private var userIsInTheMiddleOfTyping = false
    private var displayValue: Double? { /* ... as before ... */
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            guard let text = display.text, text != "Error",
                  let number = formatter.number(from: text)?.doubleValue else {
                return nil
            }
            return number
        }
        set {
            if let value = newValue {
                display.text = formatNumber(value)
            } else {
                if display.text != "Error" {
                    display.text = "0"
                }
            }
            if display.text != "Error" {
                userIsInTheMiddleOfTyping = false
                updateClearButton(isTyping: false)
            }
        }
    }

    // --- Added Property for Operator Highlight ---
    private var highlightedOperatorButton: UIButton?


    // --- Initialization (as before) ---
    init() { /* ... as before ... */
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get AppDelegate")
        }
        service = CalculatorService(context: appDelegate.persistentContainer.viewContext)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // --- View Lifecycle (as before) ---
    override func viewDidLoad() { /* ... as before ... */
        super.viewDidLoad()
        print("ViewController viewDidLoad()")
        setupNavigationBar()
        setupUI()
        displayValue = 0
    }
    override func viewDidLayoutSubviews() { /* ... as before ... */
        super.viewDidLayoutSubviews()
        print("ViewController viewDidLayoutSubviews() - Applying manual frames")
        layoutCalculatorSubviews()
    }

    // --- Setup (as before) ---
    private func setupNavigationBar() { /* ... as before ... */
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(showHistory)
        )
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.background
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Colors.historyButtonTint
    }
    private func setupUI() { /* ... as before ... */
        view.backgroundColor = Colors.background
        view.addSubview(display)
        view.addSubview(clearButton)
        view.addSubview(deleteButton)
        view.addSubview(percentButton)
        view.addSubview(equalsButton)
        numberButtons.forEach { view.addSubview($0) }
        operatorButtons.forEach { view.addSubview($0) }
    }

    // --- Layout (Manual Frames with Constants) ---
    private func layoutCalculatorSubviews() {
        // --- Layout Constants ---
        let totalButtonRows = 5
        let totalButtonColumns = 4
        let buttonSpacing: CGFloat = 8
        let sidePadding: CGFloat = 10
        let displayHeightRatio: CGFloat = 0.25 // As fraction of safe area height
        let maxDisplayHeight: CGFloat = 150
        let displayBottomMargin: CGFloat = buttonSpacing * 2 // Space between display and top buttons
        let buttonCornerRadiusRatio: CGFloat = 0.2 // Multiplier for corner radius based on size

        // --- Calculations ---
        let bounds = view.bounds
        let safeArea = view.safeAreaInsets
        let bottomPadding = safeArea.bottom > 0 ? safeArea.bottom : sidePadding

        let availableWidth = bounds.width - (2 * sidePadding) - (CGFloat(totalButtonColumns - 1) * buttonSpacing)
        let buttonWidth = availableWidth / CGFloat(totalButtonColumns)

        let safeHeight = bounds.height - safeArea.top - safeArea.bottom
        let displayHeight = min(safeHeight * displayHeightRatio, maxDisplayHeight)
        // Position display lower - Calculate top space needed for display+margin
        let displayAreaHeight = safeHeight * (displayHeightRatio + 0.05) // Allocate slightly more than just display height ratio
        let displayY = safeArea.top + (displayAreaHeight - displayHeight) // Position near bottom of allocated area
        let displaySidePadding: CGFloat = sidePadding + 8
        display.frame = CGRect(x: displaySidePadding, y: displayY, width: bounds.width - (2 * displaySidePadding), height: displayHeight)

        let topButtonY = display.frame.maxY + displayBottomMargin
        let availableButtonHeightArea = bounds.height - topButtonY - bottomPadding - (CGFloat(totalButtonRows - 1) * buttonSpacing)
        let buttonHeight = availableButtonHeightArea / CGFloat(totalButtonRows)

        let cornerRadius = min(buttonWidth, buttonHeight) * buttonCornerRadiusRatio

        // --- Button Grid Definition (as before) ---
        let buttonGrid: [[UIButton]] = [
            [clearButton, deleteButton, percentButton, operatorButtons[3]], // C, ⌫, %, ÷
            [numberButtons[7], numberButtons[8], numberButtons[9], operatorButtons[2]], // 7, 8, 9, ×
            [numberButtons[4], numberButtons[5], numberButtons[6], operatorButtons[1]], // 4, 5, 6, −
            [numberButtons[1], numberButtons[2], numberButtons[3], operatorButtons[0]], // 1, 2, 3, +
            [numberButtons[0], numberButtons[10], equalsButton]              // 0 (wide), ., =
        ]

        // --- Frame Application (as before) ---
        for (rowIndex, row) in buttonGrid.enumerated() {
            var currentX = sidePadding
            var currentColumnIndex = 0
            for button in row {
                var currentButtonWidth = buttonWidth
                if button == numberButtons[0] { currentButtonWidth = (buttonWidth * 2) + buttonSpacing }
                let currentY = topButtonY + CGFloat(rowIndex) * (buttonHeight + buttonSpacing)
                button.frame = CGRect(x: currentX, y: currentY, width: currentButtonWidth, height: buttonHeight)
                button.layer.cornerRadius = cornerRadius
                button.clipsToBounds = true

                currentX += currentButtonWidth + buttonSpacing
                currentColumnIndex += (button == numberButtons[0] ? 2 : 1)
                if currentColumnIndex >= totalButtonColumns { break }
            }
        }
    }

    // --- Button Creation Helpers (as before) ---
    private func createStyledButton(title: String, backgroundColor: UIColor, titleColor: UIColor, action: Selector) -> UIButton { /* ... as before ... */
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    private func createNumberButtons() -> [UIButton] { /* ... as before ... */
        let titles = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        return titles.map { title in
            createStyledButton(title: title, backgroundColor: Colors.numberButtonBackground, titleColor: Colors.numberButtonText, action: #selector(numberButtonTapped))
        }
    }
    private func createOperatorButtons() -> [UIButton] { /* ... as before ... */
        let titles = ["+", "−", "×", "÷"]
        return titles.map { title in
            let opButton = createStyledButton(title: title, backgroundColor: Colors.operatorButtonBackground, titleColor: Colors.operatorButtonText, action: #selector(operatorButtonTapped))
            opButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .regular)
            return opButton
        }
    }

    // --- Helper for Visual Tap Feedback ---
    private func performTapAnimation(on button: UIButton) {
        button.alpha = 0.6 // Dim slightly
        // Restore alpha after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             // Check if alpha is still modified before resetting
             // Also check if it's the highlighted operator - don't fully restore alpha if highlighted
             if button.alpha < 1.0 && button != self.highlightedOperatorButton {
                  button.alpha = 1.0
             } else if button == self.highlightedOperatorButton {
                 // If it's the highlighted one, restore to a slightly dimmed state or keep border
                 // For border approach, alpha stays 1.0
                  button.alpha = 1.0 // Ensure alpha is 1 if using border highlight
             }
        }
    }

    // --- Helper for Operator Highlight ---
    private func resetOperatorHighlight() {
        if let highlightedButton = highlightedOperatorButton {
            // Restore original appearance (remove border)
            highlightedButton.layer.borderWidth = 0
            highlightedButton.layer.borderColor = nil
             highlightedButton.alpha = 1.0 // Ensure alpha is back to normal
            self.highlightedOperatorButton = nil
        }
    }

    // --- Actions ---
    @objc private func showHistory() { /* ... as before ... */
        performTapAnimation(on: navigationItem.rightBarButtonItem!.customView as? UIButton ?? UIButton()) // Basic animation if possible
        let historyVC = HistoryViewController()
        historyVC.history = service.fetchHistory()
        navigationController?.pushViewController(historyVC, animated: true)
    }

    @objc func numberButtonTapped(_ sender: UIButton) {
        performTapAnimation(on: sender) // Tap Feedback
        resetOperatorHighlight() // Entering number clears operator highlight

        // --- Clear Error on Digit ---
        if display.text == "Error" {
            service.clear() // Clear service state
            // Don't set displayValue=0, let digit logic handle display
        }
        // --- End Clear Error ---

        guard let digit = sender.titleLabel?.text else { return }
        // Get current text *after* potential error clear
        let currentText = (display.text == "Error") ? "0" : (display.text ?? "0")

        let maxDigits = 9
        let numbersOnly = currentText.filter { "0"..."9" ~= $0 }

        // Prevent excessive digits only if already typing
        if userIsInTheMiddleOfTyping && numbersOnly.count >= maxDigits && digit != "." { return }

        if userIsInTheMiddleOfTyping {
            // Append digit, handling decimal point
            if digit == "." && currentText.contains(".") { return }
            display.text = currentText + digit
        } else {
            // Start new number
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true // Now we are typing
        }
        updateClearButton(isTyping: true) // Show AC
    }

    @objc func operatorButtonTapped(_ sender: UIButton) {
        performTapAnimation(on: sender) // Tap Feedback

        // --- Highlight Logic ---
        resetOperatorHighlight() // Clear previous highlight first
        sender.layer.borderWidth = 2.0 // Add border for highlight
        sender.layer.borderColor = Colors.operatorHighlightBorder
        highlightedOperatorButton = sender
        // --- End Highlight ---

        if display.text == "Error" { return }

        if userIsInTheMiddleOfTyping {
            guard let value = displayValue else { display.text = "Error"; return }
            service.appendNumber(value)
            userIsInTheMiddleOfTyping = false // Operator ends number entry
        }
        // If not typing, the service handles using the existing operand (result)

        guard let operationText = sender.titleLabel?.text else { return }
        let operation: Calculator.Operation
        switch operationText {
            case "+": operation = .add
            case "−": operation = .subtract
            case "×": operation = .multiply
            case "÷": operation = .divide
            default: return
        }
        service.storeOperation(operation)
        updateClearButton(isTyping: false) // Show C (waiting for next number)
    }

    @objc func equalsButtonTapped(_ sender: UIButton) {
         performTapAnimation(on: sender) // Tap Feedback
         resetOperatorHighlight() // Equals clears operator highlight

         if display.text == "Error" { return }

         if userIsInTheMiddleOfTyping {
             guard let value = displayValue else { display.text = "Error"; return }
             service.appendNumber(value)
             // displayValue setter will set userIsInTheMiddleOfTyping to false
         }

         do {
             let result = try service.calculate()
             displayValue = result // Updates display, sets typing false, updates C/AC
         } catch CalculatorError.divisionByZero {
             display.text = "Error"
         } catch CalculatorError.insufficientOperands { // Catch specific errors if needed
              display.text = "Error" // Or handle differently
         } catch CalculatorError.invalidOperation {
              display.text = "Error" // Or handle differently
         } catch {
             display.text = "Error" // Catch any other errors
         }
         // C/AC is handled by displayValue setter
    }

    @objc func clearButtonTapped(_ sender: UIButton) {
        performTapAnimation(on: sender) // Tap Feedback
        resetOperatorHighlight() // Clear clears operator highlight
        service.clear()
        displayValue = 0 // Resets display, sets typing false, updates C/AC
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        performTapAnimation(on: sender) // Tap Feedback
        // No change to operator highlight needed when deleting digits

        if display.text == "Error" { return }

        if userIsInTheMiddleOfTyping {
            guard var currentText = display.text, !currentText.isEmpty, currentText != "0" else { return }
            currentText.removeLast()
            if currentText.isEmpty || currentText == "-" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
                updateClearButton(isTyping: false)
            } else {
                display.text = currentText
                updateClearButton(isTyping: true) // Still typing
            }
        }
    }

    @objc func percentButtonTapped(_ sender: UIButton) {
         performTapAnimation(on: sender) // Tap Feedback
         resetOperatorHighlight() // Percent often acts like equals, clearing highlight

         if display.text == "Error" { return }

         if let value = displayValue {
             let percentValue = service.applyPercent(currentValue: value)
             displayValue = percentValue // Updates display, sets typing false, updates C/AC
         }
         // C/AC is handled by displayValue setter
    }

    // --- Helpers ---
    private func updateClearButton(isTyping: Bool) { /* ... as before ... */
        let title = isTyping ? "AC" : "C"
        if clearButton.title(for: .normal) != title {
            clearButton.setTitle(title, for: .normal)
        }
    }
    private func formatNumber(_ number: Double) -> String { /* ... as before ... */
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        formatter.maximumSignificantDigits = 9
        if number == floor(number) && abs(number) < 1e9 {
             formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}