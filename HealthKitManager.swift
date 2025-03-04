//
//  HealthKitManager.swift
//  LoadWise2.0
//
//  Created by Conor Kelly on 3/4/25.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    // Define the data types we want to read
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

    // Request permission to access HealthKit data
    func requestHealthKitPermission(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [heartRateType, distanceType]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // Fetch the latest heart rate measurement
    func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample, error == nil else {
                completion(nil)
                return
            }
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate)
        }
        healthStore.execute(query)
    }

    // Fetch total distance from today's workouts
    func fetchTotalDistance(completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: distanceType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample, error == nil else {
                completion(nil)
                return
            }
            let distance = sample.quantity.doubleValue(for: HKUnit.mile())
            completion(distance)
        }
        healthStore.execute(query)
    }
}

