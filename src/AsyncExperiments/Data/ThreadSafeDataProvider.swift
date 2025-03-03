//
//  ThreadSafeDataProvider.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 02.03.2025.
//

import Foundation

/// Потокобезопасный источник информации.
public struct ThreadSafeDataProvider {
    
    // MARK: - Fields
    
    /// Очередь для взаимодействия с информацией.
    private static let _queue = DispatchQueue(label: "ru.asyncExperiments.ThreadSafeDataProvider.queue")
    
    /// Счетчик вызовов.
    private static var _callCounter = 1
    
    /// Счетчик вызовов для выдачи следующего числа.
    private static var callCounter: Int {
        get {
            let count = self._queue.sync(flags: .barrier) {
                defer {
                    self._callCounter += 1
                }
                
                return self._callCounter
            }
            
            return count
        }
        
        set {
            self._queue.sync(flags: .barrier) {
                self._callCounter = newValue
            }
        }
    }
    
    // MARK: - Methods
    
    /// Получить число.
    ///
    /// - Parameter needRandom: Нужно ли сгенерировать число случайно.
    ///
    /// - Returns: Число.
    public static func getNumber(needRandom: Bool = false) -> Int {
        let number = self.createNumber(needRandom: needRandom)
        
        return number
    }
    
    /// Сбросить счетчик.
    public static func resetCounter() {
        self.callCounter = 1
    }
    
    /// Получить число.
    ///
    /// - Parameter needRandom: Нужно ли сгенерировать случайное число.
    ///
    /// - Returns: Число.
    private static func createNumber(needRandom: Bool = false) -> Int {
        if EnvironmentVariables.SIMULATE_DELAY {
            // Симуляция долгих рассчетов или синхронного ожидания данных от стороннего поставщика (по факту в сон кидается текущий поток).
            DispatchQueue.global().sync {
                Thread.sleep(forTimeInterval: EnvironmentVariables.DELAY_TIME)
            }
        }
        
        if needRandom {
            return Int.random(in: 0...1_000)
        }
        
        return self.callCounter
    }
}
