//
//  ContentView.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house = "house.circle"
    case mic = "mic.circle"
    case headphones = "headphones.circle"
}

struct NewNavBar: View {
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    
    private var tabColor: Color {
        switch selectedTab {
        case .house:
            return .blue
        case .mic:
            return .red
        case .headphones:
            return .green
        }
    }
    
    var body: some View {
        VStack {
            if selectedTab == .house {
                Home_View()
            }
            
            if selectedTab == .mic {
                Audio_Recorder_View(audio: AudioRecorder())
            }
            
            if selectedTab == .headphones {
                //@State var selectTab: Tab = fast
                Audio_Player_View(viewModel: Audio_Player())
            }
        }
        
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? tabColor : .white)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
                .font(.system(size: 40))
            }
            .frame(width: 350, height: 80)
            .background(.black)
            .cornerRadius(25)
            .padding(.top)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .house
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        ZStack {
            Color.gray
            VStack {
                NewNavBar(selectedTab: $selectedTab)
                Spacer()
                Spacer()
                Spacer()
                
            }
            
        }
        .ignoresSafeArea()
    }
}

// Does the actual swift ui preview 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
