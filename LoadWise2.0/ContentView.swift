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
    
    var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    Text("LoadWise Calculator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
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
                    
                    if let acr = acuteChronicRatio {
                        Text("AC Ratio: \(String(format: "%.2f", acr))")
                            .foregroundColor(acr > 1.5 ? .red : .green)
                    }
                    
                    
                    
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
                    .frame(height: 300)
                    
                    Spacer()
                }
                .padding()
            }
        }
    
    private func generateSyntheticData() {
        runHistory.removeAll()
        let calendar = Calendar.current
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
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
            runHistory.append(run)
        }
    }
    
    private func calculateLoadMetrics() {
        let last7Days = runHistory.prefix(7).map { $0.trainingStressScore }.reduce(0, +) / 7.0
        let last42Days = runHistory.prefix(42).map { $0.trainingStressScore }.reduce(0, +) / 42.0
        
        acuteLoad = last7Days
        chronicLoad = last42Days
        
        if let al = acuteLoad, let cl = chronicLoad, cl > 0 {
            acuteChronicRatio = al / cl
        } else {
            acuteChronicRatio = nil
        }
        
        if let acr = acuteChronicRatio, let rhr = avgRestingHeartRate, let hrv = avgHeartRateVariability {
            overtrainingWarningIndex = (acr / 2.0) + ((rhr - 50.0) / 10.0) - (hrv / 100.0)
        } else {
            overtrainingWarningIndex = nil
        }
        
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
}

struct LoadScoreChartView: View {
    var runHistory: [RunData]
    @State private var selectedRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Last 7 Days"
        case month = "Last 30 Days"
    }
    
    var filteredData: [RunData] {
        let days = selectedRange == .week ? 7 : 30
        return Array(runHistory.prefix(days))
    }
    
    var body: some View {
        VStack {
            Text("Training Load Over Time")
                .font(.headline)
                .padding(.top)
            
            Picker("Time Range", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \ .self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Chart {
                ForEach(filteredData, id: \ .date) { run in
                    LineMark(
                        x: .value("Date", run.date),
                        y: .value("Acute Load", run.trainingStressScore)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    LineMark(
                        x: .value("Date", run.date),
                        y: .value("Chronic Load", run.trainingStressScore / 6.0) // Example scaling for chronic load
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
            }
            .frame(height: 300)
            .padding()
            
            Text("Blue: Acute Load | Red (Dashed): Chronic Load")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct LoadScoreChartView_Previews: PreviewProvider {
    static var previews: some View {
        LoadScoreChartView(runHistory: sampleRunData)
    }
}
