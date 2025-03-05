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

    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let restingEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
    private let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let runningPowerType = HKQuantityType.quantityType(forIdentifier: .runningPower)!
    private let runningSpeedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
    private let strideLengthType = HKQuantityType.quantityType(forIdentifier: .runningStrideLength)!
    private let verticalOscillationType = HKQuantityType.quantityType(forIdentifier: .runningVerticalOscillation)!
    private let groundContactTimeType = HKQuantityType.quantityType(forIdentifier: .runningGroundContactTime)!
    
    
    func requestHealthKitPermission(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [
            heartRateType, distanceType, activeEnergyType, restingEnergyType, stepsType,
            runningPowerType, runningSpeedType, strideLengthType, verticalOscillationType,
            groundContactTimeType
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    private func fetchMostRecentSample(for type: HKQuantityType, unit: HKUnit, completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample, error == nil else {
                completion(nil)
                return
            }
            completion(sample.quantity.doubleValue(for: unit))
        }
        healthStore.execute(query)
    }
    
    func fetchAvgHeartRate(forWorkout workout: HKWorkout, completion: @escaping (Double?) -> Void) {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let average = result?.averageQuantity() else {
                completion(nil)
                return
            }
            completion(average.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
        }
        healthStore.execute(query)
    }
    
    func fetchTotalWalkingRunningDistance(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: distanceType, unit: HKUnit.meter(), completion: completion)
    }
    
    func fetchTotalActiveEnergy(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: activeEnergyType, unit: HKUnit.kilocalorie(), completion: completion)
    }
    
    func fetchTotalRestingEnergy(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: restingEnergyType, unit: HKUnit.kilocalorie(), completion: completion)
    }
    
    func fetchTotalSteps(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: stepsType, unit: HKUnit.count(), completion: completion)
    }
    
    func fetchAvgRunningPower(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: runningPowerType, unit: HKUnit.watt(), completion: completion)
    }
    
    func fetchAvgRunningSpeed(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: runningSpeedType, unit: HKUnit.meter().unitDivided(by: HKUnit.second()), completion: completion)
    }
    
    func fetchAvgRunningStrideLength(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: strideLengthType, unit: HKUnit.meter(), completion: completion)
    }
    
    func fetchAvgVerticalOscillation(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: verticalOscillationType, unit: HKUnit.meter(), completion: completion)
    }
    
    func fetchAvgGroundContactTime(completion: @escaping (Double?) -> Void) {
        fetchMostRecentSample(for: groundContactTimeType, unit: HKUnit.second(), completion: completion)
    }
    
    func fetchLatestWorkout(completion: @escaping (HKWorkout?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let workout = results?.first as? HKWorkout, error == nil else {
                completion(nil)
                return
            }
            completion(workout)
        }
        
        healthStore.execute(query)
    }

}
