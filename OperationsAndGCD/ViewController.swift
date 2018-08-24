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
        
        sumTwoAsyncOperations(number1: 4,
                              number2: 4,
                              number3: 5,
                              number4: 5) { (result) in
            
            print(result)
        }
        
        sumGcdTwoSyncAsyncNesting(number1: 8,
                                  number2: 8,
                                  number3: 9,
                                  number4: 9) { (result) in
                                    
            print(result)
        }
        
        sumGcdTwoSyncAsyncSemaphore(number1: 10,
                                    number2: 10,
                                    number3: 11,
                                    number4: 11) { (result) in
                            
            print(result)
        }
        
        sumGcdTwoSyncAsyncDispatchGroup(number1: 12,
                                        number2: 12,
                                        number3: 13,
                                        number4: 13) { (result) in
                                        
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
    
    // Presents the case to show that using asynchronous code within the operation
    // doesn't mean the completion will depend on result of asynchronous callback
    // in our case the result was:
    //
    // Operation 2 finished!
    // Operation Sum of 3 + 3 = 6
    // GCD Sum of 1 + 1 = 2
    // Operation 2 Sum of 5 + 5 = 10
    // Operation 1 Sum of 4 + 4 = 8
    // OperationBlock Sum of 2 + 2 = 4
    //
    // but naively we would expect:
    //
    // Operation Sum of 3 + 3 = 6
    // GCD Sum of 1 + 1 = 2
    //
    // Operation 1 Sum of 4 + 4 = 8
    // Operation 2 Sum of 5 + 5 = 10
    // Operation 2 finished!
    //
    // OperationBlock Sum of 2 + 2 = 4
    func sumTwoAsyncOperations(number1: Int,
                               number2: Int,
                               number3: Int,
                               number4: Int, completion: @escaping ((String) -> Void)) {
        
        let queue = OperationQueue()
        let operation1 = SumOfTwoAsyncOperation(number1: number1, number2: number2)
        let operation2 = SumOfTwoAsyncOperation(number1: number3, number2: number4)
        let operation3 = BlankOperation()
        operation2.addDependency(operation1)
        operation3.addDependency(operation2)
        
        operation1.completionBlock = {
            
            completion("Operation 1 Sum of \(number1) + \(number2) = \(operation1.result ?? 0)")
        }
        operation2.completionBlock = {
            
            completion("Operation 2 Sum of \(number3) + \(number4) = \(operation2.result ?? 0)")
        }
        operation3.completionBlock = {
            
            print("Operation 2 finished!")
        }
        
        queue.addOperation(operation1)
        queue.addOperation(operation2)
        queue.addOperation(operation3)
    }
    
    func sumGcdTwoSyncAsyncNesting(number1: Int,
                                             number2: Int,
                                             number3: Int,
                                             number4: Int, completion: @escaping ((String) -> Void)) {
        
        DispatchQueue.global().async {
            
            completion("GCD Sum of \(number1) + \(number2) = \(Addition().sumOfTwo(number1: number1, number2: number2))")
            
            DispatchQueue.global().async {
                
                completion("GCD Sum of \(number3) + \(number4) = \(Addition().sumOfTwo(number1: number3, number2: number4))")
            }
        }
    }
    
    func sumGcdTwoSyncAsyncSemaphore(number1: Int,
                                               number2: Int,
                                               number3: Int,
                                               number4: Int, completion: @escaping ((String) -> Void)) {
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global()
        queue.async {
            
            completion("GCD Sum of \(number1) + \(number2) = \(Addition().sumOfTwo(number1: number1, number2: number2))")
            semaphore.signal()
        }
        let _ = semaphore.wait(timeout: .now() + 2.0)
        
        queue.async {
            
            completion("GCD Sum of \(number3) + \(number4) = \(Addition().sumOfTwo(number1: number3, number2: number4))")
        }
    }
    
    func sumGcdTwoSyncAsyncDispatchGroup(number1: Int,
                                         number2: Int,
                                         number3: Int,
                                         number4: Int, completion: @escaping ((String) -> Void)) {
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        group.enter()
        queue.async(group: group) {
            
            completion("GCD Sum of \(number1) + \(number2) = \(Addition().sumOfTwo(number1: number1, number2: number2))")
            group.leave()
        }
        let _ = group.wait(timeout:  .now() + 2.0)
        
        group.notify(queue: queue) {
            
            queue.async {
                
                completion("GCD Sum of \(number3) + \(number4) = \(Addition().sumOfTwo(number1: number3, number2: number4))")
            }
        }
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
    }
}

class SumOfTwoAsyncOperation: Operation {
    
    private(set) var result: Int?
    let number1: Int
    let number2: Int
    private enum State {
        case ready
        case executing
        case finished
    }
    private var state = State.ready
    
    init(number1: Int, number2:Int) {
        
        self.number1 = number1
        self.number2 = number2
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    override var isFinished: Bool {
        return state == .finished
    }
    override func start() {
        state = .executing
        
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.result = Addition().sumOfTwo(number1: strongSelf.number1,
                                                    number2: strongSelf.number2)
            strongSelf.willChangeValue(forKey: "isFinished")
            strongSelf.state = .finished
            strongSelf.didChangeValue(forKey: "isFinished")
        }
    }
}

class SumOfTwoSyncAsyncOperation: Operation {
    
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
        
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.result = Addition().sumOfTwo(number1: strongSelf.number1, number2: strongSelf.number2)
            semaphore.signal()
        }
        let _ = semaphore.wait(timeout: .now() + 10.0)
    }
}

class BlankOperation: Operation {
    
    override func main() {}
}

struct Addition {
    
    func sumOfTwo(number1: Int, number2:Int) -> Int {
        
        return number1 + number2
    }
}







