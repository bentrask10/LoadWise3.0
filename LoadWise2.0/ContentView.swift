import SwiftUI
import Charts

struct RunData {
    let date: Date
    let duration: Double // in minutes
    let distance: Double // in km
    let avgHeartRate: Double
    let avgRunningPower: Double
    let totalSteps: Int
    let avgGroundContactTime: Double
    let avgVerticalOscillation: Double
    let totalActiveEnergy: Double
    let totalRestingEnergy: Double
    let trainingStressScore: Double // TSS
    let restingHeartRate: Double // RHR
    let heartRateVariability: Double // HRV
    let heartRateRecovery: Double // HRR
    let vo2Max: Double // VO₂ Max
    let overtrainingWarningIndex: Double // OWI
}

struct LoadScoreEntry: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct ContentView: View {
    @State private var runHistory: [RunData] = []
    @State private var acuteLoad: Double? = nil
    @State private var chronicLoad: Double? = nil
    @State private var acuteChronicRatio: Double? = nil
    @State private var avgRestingHeartRate: Double? = nil
    @State private var avgHeartRateVariability: Double? = nil
    @State private var avgHeartRateRecovery: Double? = nil
    @State private var avgVo2Max: Double? = nil
    @State private var overtrainingWarningIndex: Double? = nil
    @State private var alertMessage: String? = nil
    @State private var injuryRiskScore: Double? = nil
    @State private var loadScoreChartData: [LoadScoreEntry] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("LOADWISE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 10) {
                        Text("📊 LoadWise Dashboard")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        GeometryReader { geometry in
                            HStack(spacing: 12) {
                                DashboardCard(
                                    title: "Load Score",
                                    value: String(format: "%.2f", acuteChronicRatio ?? 0.0),
                                    unit: "AC Ratio",
                                    threshold: 1.5,
                                    lowText: "Good Training",
                                    highText: "Overtraining Risk",
                                    color: .blue,
                                    details: "AC Ratio compares short-term training load to long-term trends."
                                )
                                .frame(width: geometry.size.width / 3 - 10) // Even spacing
                                
                                DashboardCard(
                                    title: "Recovery",
                                    value: String(format: "%.2f", avgHeartRateVariability ?? 0.0),
                                    unit: "HRV (ms)",
                                    threshold: 50,
                                    lowText: "Need More Rest",
                                    highText: "Recovered",
                                    color: .green,
                                    details: "HRV measures recovery. A higher value means better recovery."
                                )
                                .frame(width: geometry.size.width / 3 - 10)
                                
                                DashboardCard(
                                    title: "Injury Risk",
                                    value: String(format: "%.2f", injuryRiskScore ?? 0.0),
                                    unit: "/100",
                                    threshold: 60,
                                    lowText: "Low Risk",
                                    highText: "High Risk",
                                    color: .red,
                                    details: "Your Injury Risk Score is based on training spikes and recovery."
                                )
                                .frame(width: geometry.size.width / 3 - 10)
                            }
                        }
                        .frame(height: 150) // Gives proper height to HStack
                        .padding(.horizontal, 10) // Adds padding so cards don’t touch screen edges
                    }
                }


                    Button(action: generateSyntheticData) {
                        Text("Generate Sample Data")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: calculateLoadMetrics) {
                        Text("Calculate Load Metrics")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if !loadScoreChartData.isEmpty {
                            Text("Load Score Trend (Last 7 Days)")
                                .font(.headline)
                            
                            Chart(loadScoreChartData) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Load Score", entry.score)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(entry.score > 120 ? Color.red : entry.score > 80 ? Color.orange : Color.blue)
                                
                                PointMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Load Score", entry.score)
                                )
                                .foregroundStyle(entry.score > 120 ? .red : .blue)
                                
                                RuleMark(
                                    x: .value("Date", entry.date)
                                )
                                .foregroundStyle(.gray.opacity(0.5))
                                .annotation(position: .top, alignment: .center) {
                                    Text("\(Int(entry.score))")
                                        .font(.caption)
                                        .bold()
                                        .padding(5)
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(5)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let date = value.as(Date.self) {
                                            Text(date.formatted(.dateTime.day().month(.abbreviated)))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        if let score = value.as(Double.self) {
                                            Text("\(Int(score))")
                                        }
                                    }
                                }
                            }
                            .frame(height: 250)
                            .padding()
                        }
                        
                        if let acr = acuteChronicRatio {
                            VStack {
                                Text("Overtraining Risk")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Gauge(value: acr, in: 0...2.0) {
                                    Text("AC Ratio")
                                }
                                .gaugeStyle(.accessoryCircularCapacity)
                                .tint(acr > 1.5 ? .red : .green)
                                .frame(width: 150, height: 150)
                                .padding()
                                
                                if acr > 1.5 {
                                    Text("Training load is too high! Consider a lighter day.")
                                        .foregroundColor(.red)
                                        .padding()
                                        .transition(.opacity)
                                        .animation(.easeInOut, value: acr)
                                }
                            }
                        }

                        
                        if let acr = acuteChronicRatio {
                            Text("AC Ratio: \(String(format: "%.2f", acr))")
                                .foregroundColor(acr > 1.5 ? .red : .green)
                            
                            let experience = UserDefaults.standard.string(forKey: "userExperience") ?? "Beginner"
                            let ageGroup = UserDefaults.standard.string(forKey: "userAgeGroup") ?? "18-29"
                            
                            let overtrainingThreshold = (experience == "Beginner" ? 1.2 : experience == "Intermediate" ? 1.3 : 1.5) -
                            ((ageGroup == "50-59" || ageGroup == "60+") ? 0.2 : 0.0)
                            
                            if acr > overtrainingThreshold {
                                Text(" Your training load is increasing too fast! As a \(experience.lowercased()), aim for a gradual build-up.")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding()
                            } else {
                                Text("Your training is progressing well! Keep maintaining consistency.")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                                    .padding()
                            }
                        }
                        
                        
                        if let riskScore = injuryRiskScore {
                            VStack {
                                Text("Injury Risk Score: \(Int(riskScore))/100")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(riskScore > 60 ? .red : (riskScore > 30 ? .yellow : .green))
                                
                                ProgressView(value: riskScore, total: 100)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(width: 250)
                                    .tint(riskScore > 60 ? .red : (riskScore > 30 ? .yellow : .green))
                                    .padding()

                                if riskScore > 60 {
                                    Text("High risk of injury! Reduce training load and focus on recovery.")
                                        .foregroundColor(.red)
                                        .padding()
                                } else if riskScore > 30 {
                                    Text("Moderate risk. Consider a recovery day or adjusting intensity.")
                                        .foregroundColor(.yellow)
                                        .padding()
                                } else {
                                    Text("Low risk. Keep training consistently!")
                                        .foregroundColor(.green)
                                        .padding()
                                }
                            }
                        }
                        
                        // Recovery Insights Section
                        VStack(spacing: 10) {
                            Text("Recovery Insights")
                                .font(.title2)
                                .fontWeight(.bold)

                            if let hrv = avgHeartRateVariability, hrv < 50 {
                                Text("Your HRV is low! Consider a recovery day.")
                                    .foregroundColor(.orange)
                                    .padding()
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(8)
                            }

                            if let hrr = avgHeartRateRecovery, hrr < 12 {
                                Text("Your heart rate recovery is slow. Fatigue detected.")
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()


                        
                        if let owi = overtrainingWarningIndex {
                            Text("Overtraining Warning Index: \(String(format: "%.2f", owi))")
                                .foregroundColor(owi > 1.0 ? .red : .green)
                        }
                        
                        if let rhr = avgRestingHeartRate, let hrv = avgHeartRateVariability, let hrr = avgHeartRateRecovery, let vo2 = avgVo2Max {
                            Text("Avg Resting HR: \(String(format: "%.2f", rhr)) bpm")
                            Text("Avg HRV: \(String(format: "%.2f", hrv)) ms")
                            Text("Avg HRR: \(String(format: "%.2f", hrr)) bpm")
                            Text("Avg VO₂ Max: \(String(format: "%.2f", vo2)) ml/kg/min")
                        }
                        
                        if let message = alertMessage {
                            Text(message)
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.yellow.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        List(runHistory, id: \ .date) { run in
                            VStack(alignment: .leading) {
                                Text("Date: \(formatDate(run.date))")
                                    .font(.headline)
                                Text("Distance: \(String(format: "%.2f", run.distance)) km")
                                Text("Avg HR: \(String(format: "%.0f", run.avgHeartRate)) bpm")
                                Text("TSS (Load Score): \(String(format: "%.2f", run.trainingStressScore))")
                                Text("Resting HR: \(String(format: "%.2f", run.restingHeartRate)) bpm")
                                Text("HRV: \(String(format: "%.2f", run.heartRateVariability)) ms")
                                Text("HRR: \(String(format: "%.2f", run.heartRateRecovery)) bpm")
                                Text("VO₂ Max: \(String(format: "%.2f", run.vo2Max)) ml/kg/min")
                                Text("OWI: \(String(format: "%.2f", run.overtrainingWarningIndex))")
                            }
                            VStack(alignment: .leading) {
                                Text("Date: \(formatDate(run.date))")
                                    .font(.headline)
                                Text("Distance: \(String(format: "%.2f", run.distance)) km")
                                Text("Avg HR: \(String(format: "%.0f", run.avgHeartRate)) bpm")
                                Text("TSS: \(String(format: "%.2f", run.trainingStressScore))")
                                Text("Resting HR: \(String(format: "%.2f", run.restingHeartRate)) bpm")
                                Text("HRV: \(String(format: "%.2f", run.heartRateVariability)) ms")
                                Text("HRR: \(String(format: "%.2f", run.heartRateRecovery)) bpm")
                                Text("VO₂ Max: \(String(format: "%.2f", run.vo2Max)) ml/kg/min")
                                Text("OWI: \(String(format: "%.2f", run.overtrainingWarningIndex))")
                            }
                        }
                        
                        List(runHistory, id: \.date) { run in
                            VStack(alignment: .leading) {
                                Text("Date: \(formatDate(run.date))")
                                    .font(.headline)
                                Text("Distance: \(String(format: "%.2f", run.distance)) km")
                                Text("Avg HR: \(String(format: "%.0f", run.avgHeartRate)) bpm")
                                Text("TSS (Load Score): \(String(format: "%.2f", run.trainingStressScore))")
                            }
                        }
                        .frame(height: 300)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    
    private func generateSyntheticData() {
        runHistory.removeAll() // Clear existing data
        let calendar = Calendar.current
        var uniqueRuns: [Date: RunData] = [:] // Store only one run per day

        for i in 0..<30 {
            let date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -i, to: Date())!) // Ensure date is at midnight
            
            let duration = Double.random(in: 30...90)
            let distance = duration / 10.0 + Double.random(in: -1...1)
            let avgHeartRate = Double.random(in: 130...180)
            let avgRunningPower = Double.random(in: 200...350)
            let totalSteps = Int(distance * 1400 + Double.random(in: -500...500))
            let avgGroundContactTime = Double.random(in: 200...300)
            let avgVerticalOscillation = Double.random(in: 5...12)
            let totalActiveEnergy = distance * 70 + Double.random(in: -50...50)
            let totalRestingEnergy = Double.random(in: 1500...2000)
            let restingHeartRate = Double.random(in: 50...65)
            let heartRateVariability = Double.random(in: 40...100)
            let heartRateRecovery = Double.random(in: 10...25)
            let vo2Max = Double.random(in: 40...55)
            let lactateThresholdHR = 165.0
            let intensityFactor = avgHeartRate / lactateThresholdHR
            let tss = (duration / 60.0) * pow(intensityFactor, 2) * 100.0
            let owi = (tss / 100.0) + (restingHeartRate / 60.0) - (heartRateVariability / 100.0)

            let run = RunData(
                date: date,
                duration: duration,
                distance: distance,
                avgHeartRate: avgHeartRate,
                avgRunningPower: avgRunningPower,
                totalSteps: totalSteps,
                avgGroundContactTime: avgGroundContactTime,
                avgVerticalOscillation: avgVerticalOscillation,
                totalActiveEnergy: totalActiveEnergy,
                totalRestingEnergy: totalRestingEnergy,
                trainingStressScore: tss,
                restingHeartRate: restingHeartRate,
                heartRateVariability: heartRateVariability,
                heartRateRecovery: heartRateRecovery,
                vo2Max: vo2Max,
                overtrainingWarningIndex: owi
            )

            uniqueRuns[date] = run // This ensures only one workout per day
        }

        runHistory = Array(uniqueRuns.values).sorted(by: { $0.date < $1.date }) // Convert to array and sort by date
    }

    
    private func calculateLoadMetrics() {
        let last7Runs = runHistory.prefix(7)
           
        // Calculate Acute Load (7-day rolling average of TSS)
        let last7DaysTSS = last7Runs.map { $0.trainingStressScore }
        acuteLoad = last7DaysTSS.reduce(0, +) / Double(last7DaysTSS.count)

        // Calculate Chronic Load (42-day rolling average of TSS)
        let last42Runs = runHistory.prefix(42)
        let last42DaysTSS = last42Runs.map { $0.trainingStressScore }
        chronicLoad = last42DaysTSS.reduce(0, +) / Double(last42DaysTSS.count)

        // Calculate AC Ratio
        if let al = acuteLoad, let cl = chronicLoad, cl > 0 {
            acuteChronicRatio = al / cl
        }
        
        // Get user preferences from UserDefaults
        let experience = UserDefaults.standard.string(forKey: "userExperience") ?? "Beginner"
        let ageGroup = UserDefaults.standard.string(forKey: "userAgeGroup") ?? "18-29"

        // Adjust AC Ratio threshold based on user profile
        var overtrainingThreshold: Double = 1.5 // Default for experienced runners

        switch experience {
        case "Beginner":
            overtrainingThreshold = 1.2
        case "Intermediate":
            overtrainingThreshold = 1.3
        case "Expert":
            overtrainingThreshold = 1.5
        default:
            overtrainingThreshold = 1.5
        }

        // Older runners may have lower thresholds
        if ageGroup == "50-59" || ageGroup == "60+" {
            overtrainingThreshold -= 0.2
        }

        // Calculate Overtraining Warning Index
        if let acr = acuteChronicRatio, let rhr = avgRestingHeartRate, let hrv = avgHeartRateVariability {
            overtrainingWarningIndex = (acr / 2.0) + ((rhr - 50.0) / 10.0) - (hrv / 100.0)
        }
        
        let last7DaysRHR = last7Runs.map { $0.restingHeartRate }
        let avgRHR = last7DaysRHR.reduce(0, +) / Double(last7DaysRHR.count)
        avgRestingHeartRate = avgRHR
        let rhrRisk = (avgRHR > (last7DaysRHR.first ?? avgRHR) + 5) ? 20 : 0

        if let firstRHR = last7DaysRHR.first, avgRHR - firstRHR >= 5 {
            alertMessage = "Your Resting HR has increased by 5+ bpm in the last week. Possible fatigue or overtraining."
        }
        
        let last7DaysHRV = last7Runs.map { $0.heartRateVariability }
        let avgHRV = last7DaysHRV.reduce(0, +) / Double(last7DaysHRV.count)
        avgHeartRateVariability = avgHRV
        let hrvRisk = (avgHRV < (last7DaysHRV.first ?? avgHRV) - 15) ? 20 : 0
        
        if let firstHRV = last7DaysHRV.first, firstHRV - avgHRV >= 15 {
            alertMessage = "Your HRV has dropped significantly. You may need more recovery time."
        }
        
        let last7DaysHRR = last7Runs.map { $0.heartRateRecovery }
        let avgHRR = last7DaysHRR.reduce(0, +) / Double(last7DaysHRR.count)
        avgHeartRateRecovery = avgHRR
        let hrrRisk = (avgHRR < 12) ? 20 : 0

        if avgHRR < 12 {
            alertMessage = "Your heart rate recovery is slowing down. Consider lighter training or rest."
        }
        
        let dailyLoadSD = (last7DaysTSS.count > 1) ? stdDev(last7DaysTSS) : 1.0 // Standard deviation
        let trainingMonotony = (acuteLoad ?? 0) / dailyLoadSD
        let monotonyRisk = (trainingMonotony > 2.0) ? 20 : 0

        if trainingMonotony > 2.0 {
            alertMessage = "Your training load is too repetitive. Increase variability to avoid burnout."
        }
        
        let acrRisk = (acuteChronicRatio ?? 0) > overtrainingThreshold ? 20 : 0
        injuryRiskScore = Double(acrRisk + rhrRisk + hrvRisk + hrrRisk + monotonyRisk)

        
        loadScoreChartData = last7Runs.map { run in
            LoadScoreEntry(date: run.date, score: run.trainingStressScore)
        }.sorted(by: { $0.date < $1.date })
        
        let last7DaysVO2Max = last7Runs.map { $0.vo2Max }
        avgVo2Max = last7DaysVO2Max.reduce(0, +) / Double(last7DaysVO2Max.count)
        
        loadScoreChartData = last7Runs.map { run in
            LoadScoreEntry(date: run.date, score: run.trainingStressScore)
        }
        .sorted(by: { $0.date < $1.date }) // Sort by date
        avgRestingHeartRate = runHistory.prefix(7).map { $0.restingHeartRate }.reduce(0, +) / 7.0
        avgHeartRateVariability = runHistory.prefix(7).map { $0.heartRateVariability }.reduce(0, +) / 7.0
        avgHeartRateRecovery = runHistory.prefix(7).map { $0.heartRateRecovery }.reduce(0, +) / 7.0
        avgVo2Max = runHistory.prefix(7).map { $0.vo2Max }.reduce(0, +) / 7.0
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func stdDev(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }



    
    }

struct DashboardCard: View {
    let title: String
    let value: String
    let unit: String
    let threshold: Double
    let lowText: String
    let highText: String
    let color: Color
    let details: String
    
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity) // Ensures text wraps inside the card
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(threshold > Double(value) ?? 0 ? .green : .red)
            
            Text(unit)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(1) // Prevents text cutoff but keeps it readable
            
            Text(threshold > Double(value) ?? 0 ? lowText : highText)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(minWidth: 120, maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .shadow(radius: 3)
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails) {
            VStack(spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(details)
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button("Close") {
                    showDetails = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}



    
