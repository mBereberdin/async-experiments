//
//  ThreadExtensions.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 02.03.2025.
//

import Foundation

// Расширения для потоков.
extension Thread {
    
    /// Вывести информацию о текущем потоке если включено.
    ///
    /// - Parameter stringId: Строковый идентификатор сообщения (обычно - название метода).
    public func printInfoIfEnabled(stringId: String) {
        if !EnvironmentVariables.PRINT_THREADS {
            return
        }
        
        let threadNumber = Thread.current.value(forKeyPath: "private.seqNum") as! Int
        let threadName = threadNumber == 1 ? "main" : "background"
        let string = String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, stringId, "\(threadName), number: \(threadNumber)")
        
        print(string)
    }
}
