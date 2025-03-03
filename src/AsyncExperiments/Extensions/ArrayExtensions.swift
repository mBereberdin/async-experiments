//
//  ArrayExtensions.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 02.03.2025.
//

import Foundation

// Расширения для массивов.
extension Array {
    
    /// Вывести информацию о результате если включено.
    public func printIfEnabled() {
        if !EnvironmentVariables.PRINT_RESULT {
            return
        }
        
        print(String(format: EnvironmentVariables.RESULT_MESSAGE_TEMPLATE, self.count, self.description))
    }
}
