import Foundation

protocol CalculatorBrainProtocol {
    func setOperand(operand: Double)
    func setOperand(operand: String)
    func performOperation(symbol: String)
    func clear()
    func undo()
}

enum CalculatorOperation {
    case Constant(Double)
    case UnaryOperation((Double) -> Double)
    case BinaryOperation((Double, Double) -> Double)
    case Equals
}

class CalculatorBrain {
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var internalProgram = [AnyObject]()
    
    var result: Double {
        return accumulator
    }
    
    var programDescription: String {
        let internalProgramDescription = getProgramDescription(internalProgram)
        if internalProgramDescription == "" {
            return " "
        }
        return internalProgramDescription
    }
    
    var variableValues = [String: Double]() {
        didSet {
            print("Variable changed value!")
            let program = internalProgram
            executeProgram(program)
        }
    }
    
    // Extensions may not contain stored properties
    private var operations = [
        "π": CalculatorOperation.Constant(M_PI),
        "e": CalculatorOperation.Constant(M_E),
        "√": CalculatorOperation.UnaryOperation(sqrt),
        "cos": CalculatorOperation.UnaryOperation(cos),
        "+": CalculatorOperation.BinaryOperation({ $0 + $1 }),
        "-": CalculatorOperation.BinaryOperation({ $0 + $1 }),
        "÷": CalculatorOperation.BinaryOperation({ $0 / $1 }),
        "×": CalculatorOperation.BinaryOperation({ $0 * $1 }),
        "=": CalculatorOperation.Equals
    ]
    
    struct PendingBinaryOperationInfo {
        var firstOperand: Double
        var operation: ((Double, Double) -> Double)
    }
    
    private func executePendingOperation() {
        if pending != nil {
            accumulator = pending!.operation(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}

extension CalculatorBrain: CalculatorBrainProtocol {
    func setOperand(operand: Double) {
        if internalProgram.last as? Double != nil {
            internalProgram[internalProgram.endIndex.advancedBy(-1)] = operand
        } else {
            internalProgram.append(operand)
        }
        accumulator = operand
    }
    
    func setOperand(operand: String) {
        internalProgram.append(operand)
        accumulator = getVariableValue(operand)
        executePendingOperation()
    }
    
    func performOperation(symbol: String) {
        print("Performing operation \(symbol) on accumulator \(accumulator)")
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value): accumulator = value
            case .UnaryOperation(let function): accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingOperation()
                pending = PendingBinaryOperationInfo(firstOperand: accumulator, operation: function)
            case .Equals:
                executePendingOperation()
                return
            }
        }
        internalProgram.append(symbol)
    }
    
    func clear() {
        accumulator = 0
        internalProgram = [AnyObject]()
        pending = nil
    }
    
    func undo() {
        if internalProgram.count > 0 {
            internalProgram.removeLast()
        }
        executeProgram(internalProgram)
    }
}

extension CalculatorBrain {
    private func getProgramDescription(program: [AnyObject]) -> String {
        var description = ""
        for op in program {
            if let value = op as? Double {
                description += String(value)
            } else if let symbol = op as? String {
                if let operation = operations[symbol] {
                    switch operation {
                    case .UnaryOperation(_): description = symbol + "(" + description + ")"
                    default: description += symbol
                    }
                } else {
                    description += symbol
                }
            }
        }
        return description
    }
    
    private func executeProgram(program: [AnyObject]) {
        clear()
        print("Executing program!")
        for op in program {
            if let value = op as? Double {
                print("Found value \(value)")
                if pending != nil {
                    accumulator = pending!.operation(pending!.firstOperand, value)
                    pending = nil
                } else {
                    accumulator = value
                }
            } else if let symbol = op as? String {
                if operations[symbol] != nil {
                    print("Performing operation for symbol \(symbol)")
                    performOperation(symbol)
                } else {
                    if pending != nil {
                        accumulator = pending!.operation(pending!.firstOperand, getVariableValue(symbol))
                        print("Got value \(getVariableValue(symbol)) for \(symbol)")
                        pending = nil
                    } else {
                        accumulator = getVariableValue(symbol)
                        print("Got value \(getVariableValue(symbol)) for \(symbol)")
                    }
                }
            }
            print("Accumulator is \(accumulator)")
        }
        internalProgram = program
    }
    
    private func getVariableValue(variableName: String) -> Double {
        return variableValues[variableName] ?? 0.0
    }
}