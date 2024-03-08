//
//  Audio_Player_View.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI
import AVFoundation

struct Audio_Player_View: View {
    @StateObject var viewModel = Audio_Player()
    
    let options = ["Fast", "High Pitch", "Low Pitch", "Echo", "Reverb"]
    //@State private var name = "Fast"
    @State private var isPlaying = false
    @State private var transparency = 0.0
    
    enum Tab: String, CaseIterable {
        case fast = "Fast"
        case highpitch = "High Pitch"
        case lowpitch = "Low Pitch"
        case Echo = "Echo"
        case Reverb = "Reverb"
    }

    let allTabs = Tab.allCases

    

    var body: some View {
        
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack(spacing: 50) {
                VStack{
                    Text("Combine Modifers")
                        .font(.system(size: 44, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [.black, .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        )
                }
                .padding(.top, 60)
//                .padding(.bottom, 10)
                
                
//                ForEach(Tab.allCases, id: \.rawValue) { tab in
//                    Text(tab.rawValue)
//                        .font(.system(size:25))
//                    //Image(systemName: "play.circle")
//                }
                VStack {
                    Button(action: {
                                // Toggle the state of isPlaying
                                isPlaying.toggle()
                        viewModel.playOrPause()
                            }) {
                                VStack {
                                
                                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(isPlaying ? .red : .green)
                                        .scaleEffect(isPlaying ? 1.2 : 1.0) // Scale effect for animation
                                        .animation(.easeInOut(duration: 0.2)) // Animation duration
                                    
                                    Text(isPlaying ? "Stop" : "Play")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(isPlaying ? .red : .green)
                                }
                                .padding(.top, 30)
                                .padding(.bottom, 100)
                            }
                            
                    
                    Text("Press to Change Speed").padding(.bottom, 10)
                    
                    Picker("Select a rate", selection: $viewModel.playbackRateIndex) {
                        ForEach(0..<viewModel.allPlaybackRates.count) {
                            Text(viewModel.allPlaybackRates[$0].label)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!viewModel.isPlayerReady)
                    .padding(.bottom, 25)
                    
                    Text("Press to Change Pitch").padding(.bottom, 10)
                    
                    Picker("Select a pitch", selection: $viewModel.playbackPitchIndex) {
                      ForEach(0..<viewModel.allPlaybackPitches.count) {
                        Text(viewModel.allPlaybackPitches[$0].label)
                        
                      }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!viewModel.isPlayerReady)
                }
//                Button {
//                    //viewModel.playOrPause()
//                        
//                } label: {
//                    Text(options[0])
//                        .disabled(!viewModel.isPlayerReady)
//                        .font(.system(size:25))
//                        .foregroundColor(.black)
//                }
//                
//                Button {
//                    viewModel.playOrPause()
//                    
//                } label: {
//                    Text(options[1])
//                        .font(.system(size:25))
//                        .foregroundColor(.black)
//                }
//                
//                Button {
//                    viewModel.playOrPause()
//                    
//                } label: {
//                    Text(options[2])
//                        .font(.system(size:25))
//                        .foregroundColor(.black)
//                }
//                
//                Button {
//                    viewModel.playOrPause()
//                    
//                } label: {
//                    Text(options[3])
//                        .font(.system(size:25))
//                        .foregroundColor(.black)
//                }
//                
//                Button {
//                    viewModel.playOrPause()
//                } label: {
//                    Text(options[4])
//                        .font(.system(size:25))
//                        .foregroundColor(.black)
//                }
            }
            
            
        
//            VStack {
//                HStack{
//                    Text("Fast")
//                        .padding(20)
//                        .font(.system(size: 30))
//                        .padding(20)
//                        Spacer()
//                    Image(systemName: "play.circle")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 40))
//                                    .padding(30)
//                }
//                .frame(width: 350, height: 70)
//                .background(.blue)
//                .cornerRadius(25)
//                //.padding(.top)
//            }
//            Spacer()
//            Spacer()
//            VStack {
//                Spacer()
//                HStack {
//                    Text("High Pitch")
//                        .padding(20)
//                        .font(.system(size: 30))
//                        .padding(20)
//                        Spacer()
//                    Image(systemName: "play.circle")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 40))
//                                    .padding(30)
//                }
//                .frame(width: 350, height: 70)
//                .background(.green)
//                .cornerRadius(25)
//                //.padding(.top)
//                }
//            Spacer()
//            Spacer()
        
        }
    }
}

#Preview {
    Audio_Player_View(viewModel: Audio_Player())
}
