
import UIKit

class GraphViewController: UIViewController {
    var brain: CalculatorBrain = CalculatorBrain()
    
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(_:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeCenter(_:))))
            let tapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.focusOnAxisCenter(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.numberOfTouchesRequired = 1
            graphView.addGestureRecognizer(tapGestureRecognizer)
            updateUI()
        }
    }
    
    func setExpression(program: [AnyObject]) {
        brain.internalProgram = program
        updateUI()
    }
    
    func getExpressionResult(x: Double) -> Double {
        brain.variableValues["M"] = x
        return brain.result
    }
    
    private func updateUI() {
        if graphView != nil {
            graphView.expression = brain.programDescription
        }
    }
}
