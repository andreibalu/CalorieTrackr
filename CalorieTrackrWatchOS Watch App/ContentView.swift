//
//  ContentView.swift
//  CalorieTrackrWatchOS Watch App
//
//  Created by Andrei Tatucu on 06.06.2023.
//

import SwiftUI
import HealthKit
import WatchConnectivity


struct LeaderboardView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedTab = 0
                }) {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "person.2.fill" : "person.2")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("Friends")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                
                Button(action: {
                    selectedTab = 1
                }) {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "flag.fill" : "flag")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("Country")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                
                Button(action: {
                    selectedTab = 2
                }) {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "globe.americas.fill" : "globe.americas")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("World")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
            }
            
            // Placeholder content for leaderboard
            List(1...10, id: \.self) { index in
                HStack {
                    if (index == 1)
                    {
                        Image(systemName: "trophy.fill")
                    }
                    else if (index == 2)
                    {
                        Image(systemName: "trophy")
                    }
                    else if (index == 3)
                    {
                        Image(systemName: "rosette")
                    }
                    Text("\(leaderboardTitle(for: selectedTab)) \(index)")
                }
                .padding()
            }
            
            
        }
    }
    
    private func leaderboardTitle(for tab: Int) -> String {
        switch tab {
        case 0:
            return "Friends"
        case 1:
            return "Country"
        case 2:
            return "World"
        default:
            return ""
        }
    }
}

struct ContentView: View {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var selectedTab = 1
    @State private var showCircle = true
    @State private var shouldAnimate = false
    @State private var shouldFadeIn = false
    @State private var activeCalories = Double(UserDefaults.standard.string(forKey: "burnedCalories") ?? "0")
    @State private var eatenCalories: Double = 0
    @State private var proteinVar: Double = 0
    @State private var carbsVar: Double = 0
    @State private var fatsVar: Double = 0
    
    // Function to handle JSON deserialization
    private func readJSONObject(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data.")
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                
                if let burnedCalories = jsonObject["burnedCalories"] as? Int {
                    activeCalories = Double(burnedCalories)
                    UserDefaults.standard.setValue(activeCalories, forKey: "burnedCalories")
                }
                if let consumedCalories = jsonObject["consumedCalories"] as? Int {
                    eatenCalories = Double(consumedCalories)
                    UserDefaults.standard.setValue(eatenCalories, forKey: "consumedCalories")
                }
                if let proteins = jsonObject["proteins"] as? Int {
                    proteinVar = Double(proteins)
                    UserDefaults.standard.setValue(proteinVar, forKey: "proteins")
                }
                if let carbs = jsonObject["carbs"] as? Int {
                    carbsVar = Double(carbs)
                    UserDefaults.standard.setValue(carbsVar, forKey: "carbs")
                }
                if let fats = jsonObject["fats"] as? Int {
                    fatsVar = Double(fats)
                    UserDefaults.standard.setValue(fatsVar, forKey: "fats")
                }
            } else {
                print("Failed to parse JSON object.")
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LeaderboardView() // Show leaderboard tab
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                        .fontWeight(.light)
                }
                .tag(0)
            
            Button(action: {
                showCircle.toggle()
            }) {
                if showCircle {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 100, height: 100)
                        Text(" \(Int(eatenCalories - activeCalories!))")
                            .foregroundColor(.white)
                            .font(.system(size: 30, weight: .medium))
                    }
                } else {
                    VStack {
                        Text("eaten: \(Int(eatenCalories))")
                            .font(.title3)
                            .bold()
                            .padding()
                        Text("burned: \(Int(activeCalories!))")
                            .font(.title3)
                            .bold()
                            .padding()
                    }
                }
            }
            .frame(width: 400, height: 350)
            .tabItem {
                Label("Purple", systemImage: "circle.fill")
            }
            .background(.purple)
            .tag(1)
            
            VStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                    .overlay(
                        Text("Protein\n\(Int(proteinVar))g")
                            .font(.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(shouldFadeIn ? 1 : 0)
                            .animation(.easeIn(duration: 0.25))
                    )
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                        .overlay(
                            Text("Carbs\n\(Int(carbsVar))g")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(shouldFadeIn ? 1 : 0)
                                .animation(.easeIn(duration: 0.25))
                        )
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                        .overlay(
                            Text("Fat\n\(Int(fatsVar))g")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(shouldFadeIn ? 1 : 0)
                                .animation(.easeIn(duration: 0.25))
                        )
                    
                }
            }
            .background(Color.black)
            .tabItem {
                Label("Nutrition", systemImage: "")
            }
            .tag(2)
            .onChange(of: selectedTab) { tab in
                if tab == 2 {
                    withAnimation(.easeIn(duration: 0.25)) {
                        shouldAnimate = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        shouldFadeIn = true
                    }
                } else {
                    shouldFadeIn = true
                }
            }
        }
        .onReceive(connectivityManager.$notificationMessage) { message in
            if let jsonMessage = message?.text{
                readJSONObject(from: jsonMessage)
            }
        }
        .onAppear {
            // Set up Watch Connectivity session
           guard WCSession.isSupported() else {
               print("Watch Connectivity is not supported on this device.")
               return
           }
            
            if let savedActiveCalories = UserDefaults.standard.value(forKey: "ActiveCalories") as? Double {
                self.activeCalories = savedActiveCalories
            }
            shouldAnimate = false
            selectedTab = 1 // Set the purple tab as the default tab
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


