import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet private weak var historyLabel: UILabel?
    @IBOutlet private weak var displayLabel: UILabel?
    private var brain = CalculatorBrain()
    private var isTyping = false
    
    @IBAction private func touchDigit(sender: UIButton) {
        if let symbol = sender.currentTitle {
            if isTyping {
                if let currentlyDisplayed = displayLabel!.text {
                    displayLabel!.text = currentlyDisplayed + symbol
                } else if displayLabel != nil {
                    displayLabel!.text = symbol
                }
            } else if displayLabel != nil {
                displayLabel!.text = symbol
                isTyping = true
            }
            if let currentlyDisplayed = displayLabel!.text,
               let value = Double(currentlyDisplayed) {
                brain.setOperand(value)
            }
        }
        if historyLabel != nil {
            historyLabel!.text = brain.programDescription
        }
    }
    
    @IBAction func performAction(sender: UIButton) {
        if let symbol = sender.currentTitle where displayLabel != nil {
            brain.performOperation(symbol)
            displayLabel!.text = String(brain.result)
            
            isTyping = false
            var description = brain.programDescription
            if symbol == "=" {
                description += "="
            }
            if historyLabel != nil {
                historyLabel!.text = description
            }
        }
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        print("Setting variable value")
        if let title = sender.currentTitle,
            let currentlyDisplayed = displayLabel!.text,
            let currentValue = Double(currentlyDisplayed) {
            let symbol = title.substringFromIndex(title.startIndex.advancedBy(1))
            brain.variableValues[symbol] = currentValue
            displayLabel!.text = String(brain.result)
        }
    }
    
    @IBAction func insertVariable(sender: UIButton) {
        if let symbol = sender.currentTitle where displayLabel != nil {
            brain.setOperand(symbol)
            displayLabel!.text = symbol
            if historyLabel != nil {
                historyLabel!.text = brain.programDescription
            }
        }
    }
    
    @IBAction func touchDecimal(sender: UIButton) {
        if let symbol = sender.currentTitle {
            print("Touched decimal \(symbol)")
        }
    }
    
    @IBAction func changeState(sender: UIButton) {
        if let symbol = sender.currentTitle {
            switch symbol {
            case "C":
                if displayLabel != nil {
                    displayLabel!.text = "0.0"
                }
            case "CE":
                if displayLabel != nil {
                    displayLabel!.text = "0.0"
                }
                brain.clear()
            case "↵":
                brain.undo()
                if displayLabel != nil {
                    displayLabel!.text = String(brain.result)
                }
                if historyLabel != nil {
                    historyLabel!.text = brain.programDescription
                }
            default: break
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Doing segue")
        let destination = segue.destinationViewController
        if let graphViewController = destination as? GraphViewController {
            graphViewController.setExpression(brain.internalProgram)
        }
        print("Identifier: \(segue.identifier)")
    }
}

