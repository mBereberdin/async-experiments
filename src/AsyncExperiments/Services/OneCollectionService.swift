//
//  OneCollectionService.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 22.09.2024.
//

import Foundation

/// Сервис задач над одной коллекцией.
public class OneCollectionService {
    
    public static func executeAllExamples() {
        print("Main Sync\\Serial")
        _ = mainSyncSerial()
        DataProvider.resetCounter()
        
        print("Background Sync\\Serial")
        _ = backgroundSyncSerial()
        DataProvider.resetCounter()
    }
    
    /// Выполнить все примеры с одной коллекцией.
    public static func executeAllExamplesAsync() async {
        print("Any Async\\Serial")
        _ = await anyAsyncSerialOnAsyncMethod()
        DataProvider.resetCounter()
        
        print("Any Async\\Parallel")
        _ = await anyAsyncParallelOnTasks()
        DataProvider.resetCounter()
        
        _ = await anyAsyncParallelOnTaskGroup()
        DataProvider.resetCounter()
        
        _ = anyAsyncParallelOnDispatch()
        DataProvider.resetCounter()
    }
    
    // MARK: - Main\Background Serial
    
    /// Синхронное поочередное выполнение в главном потоке.
    ///
    /// > Tip: Результат будет заполнен последовательно.
    ///
    /// - Returns: Массив чисел.
    public static func mainSyncSerial() -> [Int] {
        let result = Measure.time(message: "Main_Sync_Serial") {
            
            return EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Синхронное поочередное выполнение в фоновом потоке.
    ///
    /// > Warning:
    /// > ```swift
    /// > DispatchQueue.global(qos: .userInitiated).asyncAndWait
    /// > ```
    /// > Запускает в главном потоке из-за оптимизации,
    /// > поэтому для синхронизации потоков используется устаревший и плохой подход с использованием `DispatchSemaphore`.
    ///
    /// - Returns: Массив чисел.
    public static func backgroundSyncSerial() -> [Int] {
        var result: [Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInitiated).async {
            if EnvironmentVariables.PRINT_THREADS {
                print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "Task", Thread.current))
            }
            
            result = Measure.time(message: "Background_Sync_Serial") {
                
                return EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
            }
            
            if EnvironmentVariables.PRINT_RESULT {
                print("\(result)\n")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return result
    }
    
    // MARK: - Any Serial
    
    /// Асинхронное поочередное выполнение в разных потоках с помощью Async метода.
    ///
    /// > Tip:
    /// > - Результат будет заполнен последовательно;
    /// > - заполнение потокобезопасно;
    /// > - само подписывание метода словом `async` позволяет ему выполняться в фоновом потоке.
    ///
    /// - Returns: Массив чисел.
    public static func anyAsyncSerialOnAsyncMethod() async -> [Int] {
        let result = await Measure.time(message: "Any_Async_Serial_On_Async_Method") {
            
            var result: [Int] = []
            for _ in EnvironmentVariables.nums {
                let value = await DataProvider.getNumberAsync()
                result.append(value)
            }
            
            return result
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    // MARK: - Any Parallel
    
    /// Асинхронное параллельное выполнение в разных потоках с помощью Task.
    ///
    /// В этом методе не используется подход для оптимизации выделения памяти и идентичного заполнения результата по типу:
    /// ```swift
    /// var tasks: [Task<Int, Never>?] = Array(repeating: nil, count: Variables.nums.count)
    /// tasks[index] = task
    /// let createdTasks = tasks.compactMap({ $0! })
    /// ```
    /// Потому что задачи заполнить результат как в источнике - нет, а выполнение с динамически расширяемым массивом,
    /// но без дополнительной коллекции и парой проходов по ним - быстрее.
    ///
    /// > Tip:
    /// > - Результат будет заполнен случайно (хоть и контроллируется последовательное ожидание задач - последовательный доступ к `getNumberAsync` - не обеспечен);
    /// > - выглядит потоконебезопасным (потому что доступ к `getNumberAsync` не ограничен на потоки);
    /// > - по сути лучше использовать taskGroup.
    ///
    /// - Returns: Массив чисел.
    public static func anyAsyncParallelOnTasks() async -> [Int] {
        let result = await Measure.time(message: "Any_Async_Parallel_On_Tasks") {
            
            // Создание задач для параллельной работы.
            var tasks: [Task<Int, Never>] = []
            for _ in EnvironmentVariables.nums {
                let task = Task {
                    if EnvironmentVariables.PRINT_THREADS {
                        print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "Task", Thread.current))
                    }
                    
                    return await DataProvider.getNumberAsync()
                }
                tasks.append(task)
            }
            
            // Опрашивание задач.
            var result: [Int] = []
            for task in tasks {
                let value = await task.value
                result.append(value)
            }
            
            return result
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Асинхронное параллельное выполнение в разных потоках с помощью TaskGroup.
    ///
    /// Отличается от ``anyAsyncParallelOnTasks()`` тем, что сам хранит `tasks`, опрашивает их и заполняет последовательно.
    ///
    /// > Tip:
    /// > - Результат будет заполнен последовательно;
    /// > - заполнение потокобезопасно.
    ///
    /// - Returns: Массив чисел.
    public static func anyAsyncParallelOnTaskGroup() async -> [Int] {
        let result = await Measure.time(message: "Any_Async_Parallel_On_TaskGroup") {
            
            return await withTaskGroup(of: Int.self) { group in
                for _ in EnvironmentVariables.nums {
                    group.addTask {
                        if EnvironmentVariables.PRINT_THREADS {
                            print(String(format: EnvironmentVariables.THREADS_MESSAGE_TEMPLATE, "Task", Thread.current))
                        }
                        
                        return await DataProvider.getNumberAsync()
                    }
                }
                
                var resultArray: [Int] = []
                for await result in group {
                    resultArray.append(result)
                }
                
                return resultArray
            }
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
    
    /// Асинхронное параллельное выполнение в разных потоках с помощью `DispatchQueue.concurrentPerform` и `DispatchQueue`.
    ///
    /// > Tip:
    /// > - Результат будет заполнен последовательно;
    /// > - заполнение потокобезопасно (за счет синхронной очереди на модифицирование результата).
    ///
    /// - Returns: Массив чисел.
    public static func anyAsyncParallelOnDispatch() -> [Int] {
        let result = Measure.time(message: "Any_Async_Parallel_On_Dispatch") {
            
            var result: [Int] = []
            let queue = DispatchQueue(label: "serial queue")
            
            DispatchQueue.concurrentPerform(iterations: EnvironmentVariables.nums.count) { _ in
                let randomendNum = DataProvider.getNumber()
                
                // Блокируем кол-во потоков для одновременного взаимодействия для потокобезопасности.
                queue.sync {
                    result.append(randomendNum)
                }
            }
            
            return result
        }
        
        if EnvironmentVariables.PRINT_RESULT {
            print("\(result)\n")
        }
        
        return result
    }
}
