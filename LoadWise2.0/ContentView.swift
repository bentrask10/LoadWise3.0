import SwiftUI

struct ContentView: View {
    @State private var heartRate: String = ""
    @State private var pace: String = ""
    @State private var distance: String = ""
    @State private var loadScore: Double? = nil
    @State private var recommendation: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("LoadWise Calculator")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Heart Rate (bpm)", text: $heartRate)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Pace (mm:ss per mile)", text: $pace)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Distance (miles)", text: $distance)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: fetchHealthKitData) {
                    Text("Import from HealthKit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: calculateLoadScore) {
                    Text("Calculate Load Score")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                if let score = loadScore {
                    Text("Load Score: \(String(format: "%.2f", score))")
                        .font(.title2)
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("Recommendation: \(recommendation)")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("LoadWise")
            .onAppear {
                requestHealthKitPermission()
            }
        }
    }
    
    private func requestHealthKitPermission() {
        HealthKitManager.shared.requestHealthKitPermission { success, error in
            if !success {
                print("HealthKit permissions not granted: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchHealthKitData() {
        HealthKitManager.shared.fetchLatestHeartRate { hr in
            if let hr = hr {
                DispatchQueue.main.async {
                    self.heartRate = String(format: "%.0f", hr)
                }
            }
        }

        HealthKitManager.shared.fetchTotalDistance { dist in
            if let dist = dist {
                DispatchQueue.main.async {
                    self.distance = String(format: "%.2f", dist)
                }
            }
        }
    }

    private func calculateLoadScore() {
        guard let hr = Double(heartRate),
              let distanceValue = Double(distance),
              let paceValue = parsePace(pace) else {
            loadScore = nil
            recommendation = "Invalid input"
            return
        }

        let paceFactor = max(1.0, 10.0 / paceValue)  // Faster pace increases load
        let distanceFactor = distanceValue / 3.1    // Normalize by 5K
        let scalingFactor = 100.0

        loadScore = (hr * paceFactor * distanceFactor) / scalingFactor

        // Provide recommendations based on Load Score
        if let score = loadScore {
            if score < 3 {
                recommendation = "Train harder!"
            } else if score >= 3 && score < 5 {
                recommendation = "Maintain current training."
            } else {
                recommendation = "Take a rest day!"
            }
        }
    }

    private func parsePace(_ pace: String) -> Double? {
        let components = pace.split(separator: ":").compactMap { Double($0) }
        guard components.count == 2 else { return nil }
        let minutes = components[0]
        let seconds = components[1] / 60.0
        return minutes + seconds
    }
}
