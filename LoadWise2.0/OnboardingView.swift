import SwiftUI

struct OnboardingView: View {
    @State private var selectedExperience: String = "Beginner"
    @State private var selectedAgeGroup: String = "18-29"
    @State private var step: Int = 1 // Track onboarding step
    @State private var isOnboardingComplete = false

    let experienceLevels = ["Beginner", "Intermediate", "Expert"]
    let ageGroups = ["18-29", "30-39", "40-49", "50-59", "60+"]

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if step == 1 {
                VStack {
                    Text("Welcome to LoadWise! 🏃‍♂️")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .transition(.slide)
                    
                    Text("Let's personalize your training recommendations.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if step == 2 {
                VStack {
                    Text("Select Your Running Experience")
                        .font(.headline)
                        .transition(.opacity)

                    Picker("Experience Level", selection: $selectedExperience) {
                        ForEach(experienceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
            } else if step == 3 {
                VStack {
                    Text("Select Your Age Group")
                        .font(.headline)
                        .transition(.opacity)

                    Picker("Age Group", selection: $selectedAgeGroup) {
                        ForEach(ageGroups, id: \.self) { age in
                            Text(age).tag(age)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
            }

            // Progress Indicator
            HStack {
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .fill(index <= step ? Color.blue : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .animation(.easeInOut, value: step)
                }
            }

            // Button to move through steps
            Button(action: {
                if step < 3 {
                    withAnimation { step += 1 } // Move to next step
                } else {
                    saveUserPreferences()
                }
            }) {
                Text(step < 3 ? "Next" : "Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(step < 3 ? Color.blue : Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $isOnboardingComplete, content: { ContentView() })
    }

    private func saveUserPreferences() {
        UserDefaults.standard.set(selectedExperience, forKey: "userExperience")
        UserDefaults.standard.set(selectedAgeGroup, forKey: "userAgeGroup")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isOnboardingComplete = true
    }
}
