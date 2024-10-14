//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Maria Mayorova on 02.10.2024.
//

import UIKit


enum CalculationError: Error {
    case dividedByZero
}

enum Operation : String {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
    case divide = "/"
    
    var priority: Int {
        switch self {
        case .multiply, .divide:
            return 1
        case .add, .subtract:
            return 2
        }
    }
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .subtract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
        
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

struct Stack<Element> {
    var array: [Element] = []
    
    mutating func push(_ item: Element) {
        array.append(item)
    }
    
    func peek() -> Element? {
        array.last
    }
    
    mutating func pop() -> Element? {
        array.popLast()
    }
    
    var isEmpty: Bool {
        array.isEmpty
    }
    
    var count: Int {
        array.count
    }
}

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        if label.text == "0" && buttonText != "," {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
        
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard 
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard 
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from:labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        resetLabel()
    }
    
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetLabel()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from:labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
        } catch {
            label.text = "Division by zero"
        }
        
        calculationHistory.removeAll()
    }

    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    @IBOutlet weak var label: UILabel!
    
    var calculationHistory: [CalculationHistoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resetLabel()
    }
    
    func calculate() throws -> Double {
        var numbers = Stack<Double>()
        var operators = Stack<Operation>()
        
        for item in calculationHistory {
            switch item {
            case .number(let number):
                numbers.push(number)
            case .operation(let operation):
                
                while !operators.isEmpty, operation.priority >= operators.peek()!.priority {
                        let rightNumber = numbers.pop()!
                        let leftNumber = numbers.pop()!
                        let lastOperation = operators.pop()!
                        let result = try lastOperation.calculate(leftNumber, rightNumber)
                        numbers.push(result)
                }
                operators.push(operation)
            }
        }
        while !operators.isEmpty {
            let rightNumber = numbers.pop()!
            let leftNumber = numbers.pop()!
            let lastOperation = operators.pop()!
            let result = try lastOperation.calculate(leftNumber, rightNumber)
            numbers.push(result)
        }
        return numbers.pop() ?? 0.0
    }
    
    func resetLabel() {
        label.text = "0"
    }

}

