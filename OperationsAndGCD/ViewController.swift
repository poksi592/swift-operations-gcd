//
//  ViewController.swift
//  OperationsAndGCD
//
//  Created by Mladen Despotovic on 10.08.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sumGcd(number1: 1, number2: 1) { (result) in
            
            print(result)
        }
        
        sumOperationBlock(number1: 2, number2: 2) { (result) in
            
            print(result)
        }
        
        sumOperation(number1: 3, number2: 3) { (result) in
            
            print(result)
        }
    }
    
    func sumGcd(number1: Int, number2:Int, completion: @escaping ((String) -> Void)) {
        
        DispatchQueue.global().async {
            
            completion("GCD Sum of \(number1) + \(number2) = \(Addition().sumOfTwo(number1: number1, number2: number2))")
        }
    }
    
    func sumOperationBlock(number1: Int, number2:Int, completion: @escaping ((String) -> Void)) {
        
        // 'queue' declared explicitly, so that we can use its possibilites at all. Implicit declaration wouldn't have any advantage over GDC at all
        let queue = OperationQueue()
        queue.addOperation {
            
            completion("OperationBlock Sum of \(number1) + \(number2) = \(Addition().sumOfTwo(number1: number1, number2: number2))")
        }
    }
    
    func sumOperation(number1: Int, number2:Int, completion: @escaping ((String) -> Void)) {
        
        let queue = OperationQueue()
        let operation = SumOfTwoOperation(number1: number1, number2: number2)
        operation.completionBlock = {
            
            completion("Operation Sum of \(number1) + \(number2) = \(operation.result ?? 0)")
        }
        
        queue.addOperation(operation)
    }
}

class SumOfTwoOperation: Operation {
    
    private(set) var result: Int?
    let number1: Int
    let number2: Int
    
    init(number1: Int, number2:Int) {
        
        self.number1 = number1
        self.number2 = number2
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        result = Addition().sumOfTwo(number1: number1, number2: number2)
        willChangeValue(forKey: "isFinished")
    }
}

struct Addition {
    
    func sumOfTwo(number1: Int, number2:Int) -> Int {
        
        return number1 + number2
    }
}







