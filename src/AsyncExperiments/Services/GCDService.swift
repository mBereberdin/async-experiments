//
//  GCDService.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 01.03.2025.
//

import Foundation

/// Сервис обработки через GCD.
public class GCDService {
    
    // MARK: - Methods
    
    /// Запустить выполнение всех примеров.
    public static func executeAllExamples() {
        print("🟡 Global\\Serial queue\n")
        GCDService.globalSerialOneWorkItemFilling()
        DataProvider.resetCounter()
        
        print("🟡 Created\\Concurrent queue\n")
        GCDService.concurrentOneItemFilling()
        DataProvider.resetCounter()
        
        GCDService.concurrentGroupOfNotThreadSafeItemsFilling()
        DataProvider.resetCounter()
        
        GCDService.concurrentGroupOfThreadSafeItemsFilling()
        ThreadSafeDataProvider.resetCounter()
    }
    
    /// Заполнение массива в глобальной последовательной фоновой очереди через один элемент очереди.
    ///
    /// Т.к. задача 1 - результат будет заполнен последовательно.
    public static func globalSerialOneWorkItemFilling() {
        let funcName = "globalSerialOneWorkItemFilling"
        
        try? Measure.time(message: funcName) {
            // Семафор для синхронизации потоков.
            let semaphore = DispatchSemaphore(value: 0)
            // Добавление и асинхронный запуск задачи на заполнение массива в глобальную последовательную очередь
            DispatchQueue.global(qos: .userInitiated).async {
                Thread.current.printInfoIfEnabled(stringId: "\(funcName)_globalQueue_start")
                
                let result = EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
                result.printIfEnabled()
                print("📦 unique: \(Set(result).count)")
                
                Thread.current.printInfoIfEnabled(stringId: "\(funcName)_globalQueue_end")
                
                // Разблокировка ожидающего потока.
                semaphore.signal()
            }
            // Блокировка текущего потока для ожидания завершения задачи.
            semaphore.wait()
        }
    }
    
    /// Заполнение массива в конкурентной фоновой очереди через один элемент очереди.
    ///
    /// Т.к. задача 1 - результат будет заполнен последовательно.
    public static func concurrentOneItemFilling() {
        let funcName = "concurrentOneItemFilling"
        
        try? Measure.time(message: funcName) {
            // Семафор для синхронизации потоков.
            let semaphore = DispatchSemaphore(value: 0)
            // Конкурентная очередь.
            let concurrentQueue = DispatchQueue(label: "ru.asyncExperiments.concurrentOneItemFilling.queue", qos: .userInitiated, attributes: .concurrent)
            // Добавление и асинхронный запуск задачи заполнения массива.
            concurrentQueue.async {
                Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue_start")
                
                let result = EnvironmentVariables.nums.map { _ in return DataProvider.getNumber() }
                result.printIfEnabled()
                print("📦 unique: \(Set(result).count)")
                
                Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue_end")
                
                // Разблокировка ожидающего потока.
                semaphore.signal()
            }
            // Блокировка текущего потока для ожидания завершения задачи.
            semaphore.wait()
        }
    }
    
    /// Заполнение массива в конкурентной фоновой очереди через группу нескольких элементов очереди с непотокобезопасным источником данных.
    ///
    /// Т.к. задач несколько и они могут выполняться одновременно, а постащик данных непотокобезопасный - несколько потоков
    /// могут обратиться за числом одновремено, в результате чего в массиве будут дубликаты.
    public static func concurrentGroupOfNotThreadSafeItemsFilling() {
        let funcName = "concurrentGroupOfItemsFilling"
        
        try? Measure.time(message: funcName) {
            // Создание конкурентной очереди.
            let concurrentQueue = DispatchQueue(label: "ru.asyncExperiments.concurrentGroupOfNotThreadSafeItemsFilling.queue", qos: .userInitiated, attributes: .concurrent)
            // Создание группы для задач.
            let group = DispatchGroup()
            
            for number in 0..<EnvironmentVariables.nums.count {
                // Добавление задачи в группу.
                group.enter()
                // Добавление и асинхронный запуск задачи в конкурентной очереди.
                concurrentQueue.async {
                    Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue.async")
                    
                    // callCounter в методе getNumber в данном случае - критическая секция.
                    // Из-за того что доступ к инкрементируемому числу не изолирован - возможны дубликаты
                    // в результирующей коллекции.
                    // Если добавить барьер на задачу - очередь просто превратиться в последовательную.
                    EnvironmentVariables.nums[number] = DataProvider.getNumber()
                    
                    // Выход задачи из группы.
                    group.leave()
                }
            }
            
            // Ожидание завершения выполнения всех задач очереди.
            group.wait()
            
            Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue_end")
            
            EnvironmentVariables.nums.printIfEnabled()
            print("📦 unique: \(Set(EnvironmentVariables.nums).count)")
        }
    }
    
    /// Заполнение массива в конкурентной фоновой очереди через группу нескольких элементов очереди с потокобезопасным источником данных.
    ///
    /// Т.к. задач несколько и они могут выполняться одновременно, а постащик данных потокобезопасный - дубликаты в результирующей коллекции исключаются.
    ///
    /// > Tip: Эффективность возрастает с длительностью выполняемой задачи. `EnvironmentVariables.DELAY_TIME = 0.0006`
    public static func concurrentGroupOfThreadSafeItemsFilling() {
        let funcName = "concurrentGroupOfThreadSafeItemsFilling"
        
        try? Measure.time(message: funcName) {
            // Создание конкурентной очереди.
            let concurrentQueue = DispatchQueue(label: "ru.asyncExperiments.concurrentGroupOfThreadSafeItemsFilling.queue", qos: .userInitiated, attributes: .concurrent)
            // Создание группы для задач.
            let group = DispatchGroup()
            
            for number in 0..<EnvironmentVariables.nums.count {
                // Добавление задачи в группу.
                group.enter()
                // Добавление и асинхронный запуск задачи в конкурентной очереди.
                concurrentQueue.async {
                    Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue.async")
                    
                    EnvironmentVariables.nums[number] = ThreadSafeDataProvider.getNumber()
                    
                    // Выход задачи из группы.
                    group.leave()
                }
            }
            
            // Ожидание завершения выполнения всех задач очереди.
            group.wait()
            
            Thread.current.printInfoIfEnabled(stringId: "\(funcName)_concurrentQueue_end")
            
            EnvironmentVariables.nums.printIfEnabled()
            print("📦 unique: \(Set(EnvironmentVariables.nums).count)")
        }
    }
}
