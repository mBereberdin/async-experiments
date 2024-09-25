//
//  SeveralCollectionsService.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 19.09.2024.
//

import Foundation

/// Сервис задач над несколькими коллекциями.
public class SeveralCollectionsService {
    
    public static func executeAllExamples() {
        print("Main Sync\\Serial")
        _ = mainSyncSerialGroup()
        
        print("Background Sync\\Serial")
        _ = backgroundSyncSerialGroup()
    }
    
    /// Выполнить все примеры с несколькими коллекциями.
    public static func executeAllExamplesAsync() async {
        print("Background Async\\Serial\\Task")
        _ = await backgroundAsyncSerialGroupOnTask()
        
        print("Background Async\\Parallel\\Tasks")
        _ = await backgroundAsyncParallelGroupOnTasks()
        
        print("Background\\Async\\Parallel\\AsyncLet")
        _ = await backgroundAsyncParallelGroupOnAsyncLet()
        
        // TODO: Background\\Async\\Parallel\\TaskGroup
        // TODO: Background\\Async\\Parallel\\Dispatch
    }
    
    // MARK: - Serial
    
    /// Синхронная поочередная обработка нескольких коллекций в главном потоке.
    ///
    /// > Tip:
    /// > - Следующая коллекция обрабатывается только после завершения текущей;
    /// > - результат будет заполнен последовательно.
    ///
    /// - Returns: Массив массивов чисел.
    public static func mainSyncSerialGroup() -> [[Int]] {
        let result = Measure.time(message: "data_Of_Main_Sync_Serial_Sync_Group") {
            
            if EnvironmentVariables.PRINT_THREADS {
                print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "mainSyncSerialGroup", Thread.current))
            }
            
            let firstCollection = fillAndReset()
            let secondCollection = fillAndReset()
            let thirdCollection = fillAndReset()
            
            return [firstCollection, secondCollection, thirdCollection]
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Синхронная поочередная обработка нескольких коллекций в фоновом потоке.
    ///
    /// Для синхронизации потоков используется устаревший и плохой подход с использованием `DispatchSemaphore`.
    ///
    /// > Tip:
    /// > - Следующая коллекция обрабатывается только после завершения текущей;
    /// > - результат будет заполнен последовательно.
    ///
    /// - Returns: Массив массивов чисел.
    public static func backgroundSyncSerialGroup() -> [[Int]] {
        var result: [[Int]] = [[]]
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if EnvironmentVariables.PRINT_THREADS {
                print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "backgroundSyncSerialGroup", Thread.current))
            }
            
            result = Measure.time(message: "data_Of_Background_Sync_Serial_Group") {
                let firstCollection = fillAndReset()
                let secondCollection = fillAndReset()
                let thirdCollection = fillAndReset()
                
                return [firstCollection, secondCollection, thirdCollection]
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    // MARK: - Tasks
    
    /// Асинхронная поочередная обработка нескольких коллекций в фоновом потоке.
    ///
    /// > Tip:
    /// > - Следующая коллекция обрабатывается только после завершения текущей;
    /// > - результат будет заполнен последовательно.
    ///
    /// - Returns: Массив массивов чисел.
    public static func backgroundAsyncSerialGroupOnTask() async -> [[Int]] {
        let result = await Measure.time(message: "data_Of_Background_Async_Serial_Group_On_Task") {
            
            let resultFillingTask = Task(priority: .userInitiated) {
                if EnvironmentVariables.PRINT_THREADS {
                    print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "backgroundAsyncSerialGroupOnTask", Thread.current))
                }
                
                let firstCollection = fillAndReset()
                let secondCollection = fillAndReset()
                let thirdCollection = fillAndReset()
                
                return [firstCollection, secondCollection, thirdCollection]
            }
            
            return await resultFillingTask.value
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Асинхронная параллельная обработка нескольких коллекций в фоновых потоках.
    ///
    /// > Tip:
    /// > - Обработка коллекций запускается почти одновременно;
    /// > - результат будет заполнен случайно (reset происходит после заполнения коллекции,
    /// > а так как коллекции заполняются параллельно - любая заполненная коллекция сбрасывает счетчик для других).
    ///
    /// - Returns: Массив массивов чисел.
    public static func backgroundAsyncParallelGroupOnTasks() async -> [[Int]] {
        let result = await Measure.time(message: "data_Of_Background_Async_Parallel_Group_On_Tasks") {
            
            let firstCollectionTask = Task(priority: .userInitiated) {
                if EnvironmentVariables.PRINT_THREADS {
                    print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "firstCollectionTask", Thread.current))
                }
                
                return fillAndReset()
            }
            
            let secondCollectionTask = Task(priority: .userInitiated) {
                if EnvironmentVariables.PRINT_THREADS {
                    print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "secondCollectionTask", Thread.current))
                }
                
                return fillAndReset()
            }
            
            let thirdCollectionTask = Task(priority: .userInitiated) {
                if EnvironmentVariables.PRINT_THREADS {
                    print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "thirdCollectionTask", Thread.current))
                }
                
                return fillAndReset()
            }
            
            return await [firstCollectionTask.value, secondCollectionTask.value, thirdCollectionTask.value]
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Асинхронная параллельная обработка нескольких коллекций в фоновых потоках.
    ///
    /// > Tip:
    /// > - Обработка коллекций запускается почти одновременно;
    /// > - результат будет заполнен случайно (reset происходит после заполнения коллекции,
    /// > а так как коллекции заполняются параллельно - любая заполненная коллекция сбрасывает счетчик для других).
    ///
    /// - Returns: Массив массивов чисел.
    public static func backgroundAsyncParallelGroupOnAsyncLet() async -> [[Int]] {
        let result = await Measure.time(message: "data_Of_Background_Async_Parallel_Group_On_AsyncLet") {
            
            async let firstCollection = fillAndReset()
            async let secondCollection = fillAndReset()
            async let thirdCollection = fillAndReset()
            
            return await [firstCollection, secondCollection, thirdCollection]
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    // MARK: - Helpers
    
    /// Заполнить и сбросить.
    ///
    /// - Returns: Массив чисел.
    private static func fillAndReset() -> [Int] {
        if EnvironmentVariables.PRINT_THREADS {
            print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "fillAndReset", Thread.current))
        }
        
        defer {
            DataProvider.resetCounter()
        }
        
        return EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
    }
    
    /// Заполнить и сбросить.
    ///
    /// - Returns: Массив чисел.
    private static func fillAndResetAsync() async -> [Int] {
        if EnvironmentVariables.PRINT_THREADS {
            print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "fillAndResetAsync", Thread.current))
        }
        
        defer {
            DataProvider.resetCounter()
        }
        
        return EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
    }
}
