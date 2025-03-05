//
//  LoadWise2_0App.swift
//  LoadWise2.0
//
//  Created by Conor Kelly on 2/10/25.
//

import SwiftUI

@main
struct LoadWiseApp: App {
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
