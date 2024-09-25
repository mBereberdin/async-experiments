//
//  Measure.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 19.09.2024.
//

import Foundation

/// Измерение.
public struct Measure {
    
    // MARK: - Templates
    
    /// Шаблон сообщения начала выполнения измерения.
    private static let START_MESSAGE_TEMPLATE: String = "🟢 Starting execute [%@]."
    
    /// Шаблон сообщения остановки измерения выполнения.
    private static let STOP_MESSAGE_TEMPLATE: String = "🔴 Stoped execute [%@]."
    
    /// Шаблон сообщения времени выполнения.
    private static let TIME_MESSAGE_TEMPLATE: String = "⚪️ 🏷️ %-70s ⏱️ %7.4fs. ⏸️ %5@ 🧩 %@\n"
    
    // MARK: - Methods
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time(message: String, logStates: Bool = true, code: () async -> ()) async {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        await code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time<TResult>(message: String, logStates: Bool = true, code: () async -> TResult) async -> TResult {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = await code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
        
        return result
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time<TResult>(message: String, logStates: Bool = true, code: () -> TResult) -> TResult {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
        
        return result
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time(message: String, logStates: Bool = true, code: () async throws -> ()) async throws {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        try await code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time<TResult>(message: String, logStates: Bool = true, code: () async throws -> TResult) async throws -> TResult {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
        
        return result
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time(message: String, logStates: Bool = true, code: () throws -> ()) throws {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        try code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
    }
    
    /// Измерить время выполения.
    /// - Parameters:
    ///   - message: Сообщение (маркировка метода).
    ///   - code: Код, который необходимо выполнить с замером времени выполнения.
    public static func time<TResult>(message: String, logStates: Bool = true, code: () throws -> TResult) throws -> TResult {
        if logStates {
            print(String(format: START_MESSAGE_TEMPLATE, message))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try code()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        if logStates {
            print(String(format: STOP_MESSAGE_TEMPLATE, message))
        }
        
        print(String(format: TIME_MESSAGE_TEMPLATE,
                     (message as NSString).utf8String ?? "null",
                     timeElapsed,
                     EnvironmentVariables.SIMULATE_DELAY.description,
                     EnvironmentVariables.nums.count.formatted(.number)))
        
        return result
    }
}
