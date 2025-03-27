// Content for HistoryViewController.swift
import UIKit
import CoreData // Keep if CalculatorModel is used directly

class HistoryViewController: UIViewController {

    // --- Properties ---
    private let historyTableView: UITableView = {
        let element = UITableView()
        // No translatesAutoresizingMaskIntoConstraints needed
        element.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell") // Register cell
        // Add any specific styling for the table view here
        element.backgroundColor = .black // Match dark theme
        element.separatorColor = .darkGray // Adjust separator color
        return element
    }()

    var history: [CalculatorModel] = [] // Data passed from ViewController

    // --- Initialization ---
    // Using default init(nibName:bundle:)

    // --- View Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History" // Set navigation title
        view.backgroundColor = .black // Match dark theme
        setupTableView()
        addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set frame for the table view, respecting safe area
        historyTableView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    // --- Setup ---
    private func addSubviews() {
        view.addSubview(historyTableView)
    }

    private func setupTableView() {
        historyTableView.dataSource = self
        historyTableView.delegate = self
    }

    // Helper to format numbers nicely (avoiding unnecessary .0)
    private func formatNumber(_ number: Double) -> String {
        // Use NumberFormatter for better control, especially with large/small numbers
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8 // Adjust as needed
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false // Keep it simple
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// --- TableView DataSource & Delegate ---
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let session = history[indexPath.row]

        // Configure cell appearance for dark mode
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 0 // Allow wrapping if needed
        cell.detailTextLabel?.textColor = .lightGray // If using detail label

        // Format the history entry (adjust based on CalculatorModel properties)
        let operand1String = formatNumber(session.operand1)
        // Check if operand2 is relevant for the operation type if possible
        let operand2String = formatNumber(session.operand2) // Assuming operand2 exists and is used
        let resultString = formatNumber(session.result)
        let operationSymbol = session.operationType ?? "?" // e.g., "+", "-", "×", "÷"

        // Example formatting: "12 + 34 = 46" - Adjust based on actual model structure
        // Handle potential unary operations where operand2 might not be used.
        // This assumes a binary operation structure for display.
        cell.textLabel?.text = "\(operand1String) \(operationSymbol) \(operand2String) = \(resultString)"

        // Optional: Format and display the date
        // if let date = session.date {
        //     let dateFormatter = DateFormatter()
        //     dateFormatter.dateStyle = .short
        //     dateFormatter.timeStyle = .short
        //     cell.detailTextLabel?.text = dateFormatter.string(from: date)
        // } else {
        //     cell.detailTextLabel?.text = nil
        // }


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle row selection if needed (e.g., copy result, reuse expression)
        print("Selected history item: \(history[indexPath.row])")
    }
}