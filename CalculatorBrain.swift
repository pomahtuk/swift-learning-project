//
//  CalculatorBrain.swift
//  Calculator-test
//
//  Created by Lovriakov, Ilya on 04/02/15.
//  Copyright (c) 2015 Lovriakov, Ilya. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BiaryOperation(String, (Double, Double)-> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let sumbol, _):
                    return sumbol
                case .BiaryOperation(let sumbol, _):
                    return sumbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    init () {
        
        func learnOp (op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BiaryOperation("×") { $0 * $1 })
        learnOp(Op.BiaryOperation("÷") { $1 / $0 })
        learnOp(Op.BiaryOperation("+") { $0 + $1 })
        learnOp(Op.BiaryOperation("-") { $1 - $0 })
        learnOp(Op.UnaryOperation("√") { sqrt($0) })
        learnOp(Op.UnaryOperation("Sin") { sin($0) })
        learnOp(Op.UnaryOperation("Cos") { cos($0) })
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BiaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand (operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation (sumbol: String) -> Double? {
        if let operation = knownOps[sumbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}