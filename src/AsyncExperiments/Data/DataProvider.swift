//
//  DataProvider.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 19.09.2024.
//

import Foundation

/// Поставщик информации.
public struct DataProvider {
    
    /// Счетчик вызовов для выдачи следующего числа.
    private static var callCounter = 1
    
    // MARK: - Methods
    
    /// Получить число.
    ///
    /// - Returns: Число.
    public static func getNumber(needRandom: Bool = false) -> Int {
        if EnvironmentVariables.PRINT_THREADS {
            print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "get_Random_Number", Thread.current))
        }
        
        return createNumber()
    }
    
    /// Получить число.
    ///
    /// > Warning:
    /// > ```swift
    /// > try! await Task.sleep(for: .seconds(EnvironmentVariables.DELAY_TIME))
    /// > ```
    /// > Способ симуляции ожидания как выше не используется,
    /// > потому что из-за него в разы увеличивается время ожидания.
    /// >
    /// > Возможно из-за того, что в методе нет Task, которая бы кидалась в сон. Из-за этого Task сначала создается,
    /// > потом происходит переключение на ее контекст\поток и только потом она кидается в сон,
    /// > что в сумме увеличивает время `EnvironmentVariables.DELAY_TIME` в сравнении с `Thread.sleep(forTimeInterval: EnvironmentVariables.DELAY_TIME)`.
    ///
    /// - Returns: Случайное число.
    public static func getNumberAsync() async -> Int {
        if EnvironmentVariables.PRINT_THREADS {
            print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "get_Random_Number_Async", Thread.current))
        }
        
        return createNumber()
    }
    
    /// Сбросить счетчик.
    public static func resetCounter() {
        callCounter = 1
    }
    
    // MARK: - Private
    
    /// Сгенерировать случайное число.
    ///
    /// - Returns: Случайное число.
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
        
        // TODO: Проверить что из-за строки выше не срабатывает defer.
        defer {
            callCounter += 1
        }
        
        return callCounter
    }
}
