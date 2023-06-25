//
//  ContentView.swift
//  CalorieTrackrWatchOS Watch App
//
//  Created by Andrei Tatucu on 06.06.2023.
//

import SwiftUI
import HealthKit
import WatchConnectivity


struct FadeInModifier: ViewModifier {
    @State var shouldFadeIn: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(shouldFadeIn ? 1 : 0)
            .animation(Animation.easeInOut(duration: 0.5).delay(0.2), value: UUID())
    }
}

struct LeaderboardView: View {
    @State private var selectedTab: Int = 0
    @State var consumed1Var = String(UserDefaults.standard.string(forKey: "consumed1") ?? "0")
    @State var consumed2Var = String(UserDefaults.standard.string(forKey: "consumed2") ?? "0")
    @State var consumed3Var = String(UserDefaults.standard.string(forKey: "consumed3") ?? "0")
    @State var burned1Var = String(UserDefaults.standard.string(forKey: "burned1") ?? "0")
    @State var burned2Var = String(UserDefaults.standard.string(forKey: "burned2") ?? "0")
    @State var burned3Var = String(UserDefaults.standard.string(forKey: "burned3") ?? "0")
    @State var streak1Var = String(UserDefaults.standard.string(forKey: "streak1") ?? "0")
    @State var streak2Var = String(UserDefaults.standard.string(forKey: "streak2") ?? "0")
    @State var streak3Var = String(UserDefaults.standard.string(forKey: "streak3") ?? "0")
    @State private var shouldFadeIn = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedTab = 0
                    shouldFadeIn = true
                }) {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "carrot.fill" : "carrot")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("Eaten")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                
                Button(action: {
                    selectedTab = 1
                    shouldFadeIn = true
                }) {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "figure.yoga" : "figure.stand")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("Burned")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                
                Button(action: {
                    selectedTab = 2
                    shouldFadeIn = true
                }) {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "flame.fill" : "flame")
                            .font(.system(size: 25, weight: .medium))
                            
                        Text("Streaks")
                            .font(.system(size: 10, weight: .medium))
                    }
                }
            }
            
            
            List(1...3, id: \.self) { index in
                HStack {
                    if (index == 1)
                    {
                        Image(systemName: "trophy.fill")
                        if (selectedTab == 0)
                        {
                            Text("\(consumed1Var)")
                        }
                        else if(selectedTab == 1)
                        {
                            Text("\(burned1Var)")
                        }
                        else
                        {
                            Text("\(streak1Var)")
                        }
                    }
                    else if (index == 2)
                    {
                        Image(systemName: "trophy")
                        if (selectedTab == 0)
                        {
                            Text("\(consumed2Var)")
                        }
                        else if(selectedTab == 1)
                        {
                            Text("\(burned2Var)")
                        }
                        else
                        {
                            Text("\(streak2Var)")
                        }
                    }
                    else if (index == 3)
                    {
                        Image(systemName: "rosette")
                        if (selectedTab == 0)
                        {
                            Text("\(consumed3Var)")
                        }
                        else if(selectedTab == 1)
                        {
                            Text("\(burned3Var)")
                        }
                        else
                        {
                            Text("\(streak3Var)")
                        }
                    }
                }
                .padding()
                .onAppear()
                {
                    getDataFromUserDefaults()
                }
                .onChange(of: selectedTab) { tab in
                    getDataFromUserDefaults()
                    print(selectedTab)
                }
            }
            
            
        }
    }
    
    private func getDataFromUserDefaults() {
        consumed1Var = String(UserDefaults.standard.string(forKey: "consumed1") ?? "0")
        consumed2Var = String(UserDefaults.standard.string(forKey: "consumed2") ?? "0")
        consumed3Var = String(UserDefaults.standard.string(forKey: "consumed3") ?? "0")
        burned1Var = String(UserDefaults.standard.string(forKey: "burned1") ?? "0")
        burned2Var = String(UserDefaults.standard.string(forKey: "burned2") ?? "0")
        burned3Var = String(UserDefaults.standard.string(forKey: "burned3") ?? "0")
        streak1Var = String(UserDefaults.standard.string(forKey: "streak1") ?? "0")
        streak2Var = String(UserDefaults.standard.string(forKey: "streak2") ?? "0")
        streak3Var = String(UserDefaults.standard.string(forKey: "streak3") ?? "0")
    }
}

struct ContentView: View {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var selectedTab = 1
    @State private var showCircle = true
    @State private var shouldAnimate = false
    @State private var shouldFadeIn = false
    @State private var activeCalories = Double(UserDefaults.standard.string(forKey: "burnedCalories") ?? "0")
    @State private var eatenCalories = Double(UserDefaults.standard.string(forKey: "consumedCalories") ?? "0")
    @State private var proteinVar = Double(UserDefaults.standard.string(forKey: "proteins") ?? "0")
    @State private var carbsVar = Double(UserDefaults.standard.string(forKey: "carbs") ?? "0")
    @State private var fatsVar = Double(UserDefaults.standard.string(forKey: "fats") ?? "0")
    @State private var bmrVar = Double(UserDefaults.standard.string(forKey: "bmr") ?? "1234")
    @State private var consumed1Var = String(UserDefaults.standard.string(forKey: "consumed1") ?? "0")
    @State private var consumed2Var = String(UserDefaults.standard.string(forKey: "consumed2") ?? "0")
    @State private var consumed3Var = String(UserDefaults.standard.string(forKey: "consumed3") ?? "0")
    @State private var burned1Var = String(UserDefaults.standard.string(forKey: "burned1") ?? "0")
    @State private var burned2Var = String(UserDefaults.standard.string(forKey: "burned2") ?? "0")
    @State private var burned3Var = String(UserDefaults.standard.string(forKey: "burned3") ?? "0")
    @State private var streak1Var = String(UserDefaults.standard.string(forKey: "streak1") ?? "0")
    @State private var streak2Var = String(UserDefaults.standard.string(forKey: "streak2") ?? "0")
    @State private var streak3Var = String(UserDefaults.standard.string(forKey: "streak3") ?? "0")
    
    private func getHour()
    {
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        
        print("Tatucu: hour is \(hour)")
    }
   
    private func readJSONObject(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data.")
            return
        }
        do {
            let date = Date()
            let hour = Calendar.current.component(.hour, from: date)
            print(jsonData)
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            {
                if let consumedCalories = jsonObject["consumedCalories"] as? Double {
                    eatenCalories = consumedCalories
                    UserDefaults.standard.setValue(eatenCalories, forKey: "consumedCalories")
                }
                if let proteins = jsonObject["proteins"] as? Double {
                    proteinVar = proteins
                    UserDefaults.standard.setValue(proteinVar, forKey: "proteins")
                }
                if let carbs = jsonObject["carbs"] as? Double {
                    carbsVar = carbs
                    UserDefaults.standard.setValue(carbsVar, forKey: "carbs")
                }
                if let fats = jsonObject["fats"] as? Double {
                    fatsVar = fats
                    UserDefaults.standard.setValue(fatsVar, forKey: "fats")
                }
                if let consumed1 = jsonObject["consumed1"] as? String {
                    consumed1Var = consumed1
                    UserDefaults.standard.setValue(consumed1Var, forKey: "consumed1")
                }
                if let consumed2 = jsonObject["consumed2"] as? String {
                    consumed2Var = consumed2
                    UserDefaults.standard.setValue(consumed2Var, forKey: "consumed2")
                }
                if let consumed3 = jsonObject["consumed3"] as? String {
                    consumed3Var = consumed3
                    UserDefaults.standard.setValue(consumed3Var, forKey: "consumed3")
                }
                if let burned1 = jsonObject["burned1"] as? String {
                    burned1Var = burned1
                    UserDefaults.standard.setValue(burned1Var, forKey: "burned1")
                }
                if let burned2 = jsonObject["burned2"] as? String {
                    burned2Var = burned2
                    UserDefaults.standard.setValue(burned2Var, forKey: "burned2")
                }
                if let burned3 = jsonObject["burned3"] as? String {
                    burned3Var = burned3
                    UserDefaults.standard.setValue(burned3Var, forKey: "burned3")
                }
                if let streak1 = jsonObject["streak1"] as? String {
                    streak1Var = streak1
                    UserDefaults.standard.setValue(streak1Var, forKey: "streak1")
                }
                if let streak2 = jsonObject["streak2"] as? String {
                    streak2Var = streak2
                    UserDefaults.standard.setValue(streak2Var, forKey: "streak2")
                }
                if let streak3 = jsonObject["streak3"] as? String {
                    streak3Var = streak3
                    UserDefaults.standard.setValue(streak3Var, forKey: "streak3")
                    print(streak3Var)
                }
                if let bmr = jsonObject["bmr"] as? Double {
                    bmrVar = Double(bmr * Double(hour)/24.0)
                    UserDefaults.standard.setValue(bmrVar, forKey: "bmr")
                    print(bmr)
                    print(bmrVar!)
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
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                        .fontWeight(.light)
                }
                .onChange(of: selectedTab) { tab in
                    connectivityManager.send("getData")
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
                        if((eatenCalories! - activeCalories! - bmrVar!) > 0)
                        {
                            Text("+\(Int(eatenCalories! - activeCalories! - bmrVar!))")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .medium))
                        }
                        else
                        {
                            Text(" \(Int(eatenCalories! - activeCalories! - bmrVar!))")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .medium))
                        }
                    }
                } else {
                    VStack {
                        Text("eaten: \(Int(eatenCalories!))")
                            .font(.title3)
                            .bold()
                            .padding()
                        Text("burned: \(Int(activeCalories! + bmrVar!))")
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
            .onChange(of: selectedTab) { tab in
                connectivityManager.send("getData")
            }
            .tag(1)
            
            VStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                    .overlay(
                        Text("Protein\n\(Int(proteinVar!))g")
                            .font(.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(shouldFadeIn ? 1 : 0)
                            .animation(Animation.easeIn(duration: 0.25), value:UUID())
                    )
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                        .overlay(
                            Text("Carbs\n\(Int(carbsVar!))g")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(shouldFadeIn ? 1 : 0)
                                .animation(Animation.easeIn(duration: 0.25), value:UUID())
                        )
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: shouldAnimate ? 90 : 50, height: shouldAnimate ? 90 : 50)
                        .overlay(
                            Text("Fat\n\(Int(fatsVar!))g")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(shouldFadeIn ? 1 : 0)
                                .animation(Animation.easeIn(duration: 0.25), value:UUID())
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
                connectivityManager.send("getData")
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
                print("Tatucu: bmrvar: \(bmrVar!)")
                self.activeCalories = savedActiveCalories
            }
            shouldAnimate = false
            selectedTab = 1 // Set the purple tab as the default tab
        }
    }
    private func requestAuthorizationForHealthKit() {
            guard HKHealthStore.isHealthDataAvailable() else {
                print("HealthKit is not available on this device.")
                return
            }

            let healthStore = HKHealthStore()
            let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)

            healthStore.requestAuthorization(toShare: nil, read: [activeEnergyType!]) { success, error in
                if success {
                    self.fetchActiveCalories(healthStore: healthStore)
                } else {
                    print("Failed to request HealthKit authorization: \(String(describing: error))")
                }
            }
        }

        private func fetchActiveCalories(healthStore: HKHealthStore) {
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
            let query = HKStatisticsQuery(quantityType: activeEnergyType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Failed to fetch active energy: \(String(describing: error))")
                    return
                }

                let activeEnergy = sum.doubleValue(for: .kilocalorie())
                DispatchQueue.main.async {
                    self.activeCalories = activeEnergy
                    UserDefaults.standard.setValue(activeEnergy, forKey: "burnedCalories")
                }
            }

            healthStore.execute(query)
        }

        init() {
            requestAuthorizationForHealthKit()
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


