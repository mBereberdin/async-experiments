//
//  EnvironmentVariables.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 20.09.2024.
//

import Foundation

/// Переменные окружения.
public struct EnvironmentVariables {
    
    // MARK: - Fields
    
    /// Время приостановки задачи для симулации работы\задержки.
    public static var DELAY_TIME = 0.00001
    
    /// Симулировать задержку.
    public static var SIMULATE_DELAY = true
    
    /// Числа.
    public static var nums: [Int] = Array(repeating: 0, count: 10)
    
    /// Необходимо ли печатать потоки, на которых выполняется код.
    public static var PRINT_THREADS = false
    
    /// Необходимо ли печатать результат.
    public static var PRINT_RESULT = false
    
    /// Шаблон сообщения о потоке.
    ///
    ///```swift
    /// "🧵 [%@] thread: %@"
    ///```
    public static let THREADS_MESSAGE_TEMPLATE = "🧵 [%@] thread: %@"
    
    /// Шаблон сообщения результата.
    ///
    ///```swift
    /// "📦 Result collection: count: %d items:\n%@"
    ///```
    public static let RESULT_MESSAGE_TEMPLATE = "📦 Result collection: count: %d items:\n%@"
}
