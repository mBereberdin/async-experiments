//
//  main.swift
//  AsyncExperiments
//
//  Created by Mikhail Bereberdin on 19.09.2024.
//

import Foundation

// MARK: - Configure

// Uncomment rows below for see more details.

//EnvironmentVariables.PRINT_THREADS = true
//EnvironmentVariables.PRINT_RESULT = true
//EnvironmentVariables.SIMULATE_DELAY = false
EnvironmentVariables.nums = Array(repeating: 0, count: 80_000)

// MARK: - Work here

OneCollectionService.executeAllExamples()
await OneCollectionService.executeAllExamplesAsync()

SeveralCollectionsService.executeAllExamples()
await SeveralCollectionsService.executeAllExamplesAsync()
