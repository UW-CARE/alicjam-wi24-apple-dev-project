//
//  Audio_Recorder_View.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI

struct Audio_Recorder_View: View {
    @ObservedObject var audio: AudioRecorder
    
    var body : some View {
            VStack {
                Spacer()
                Button (action: {
                    if audio.recording{
                        audio.stopRecording()
                    } else {
                        audio.startRecording()
                    }
                }, label: {
                    Image(systemName: "mic.fill.badge.plus")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(audio.recording ? .red : .green)
                        .frame(width: 70, height: 70)
                })
                
                Text(audio.recording ? "Recording..." : "Click to Record")
                    .font(.caption)
                    .bold()
                    .foregroundColor(audio.recording ? .green : .red)
                Spacer()
            }
    }
}

struct AudioRecorder_View_Previews: PreviewProvider {
    static var previews: some View {
        Audio_Recorder_View(audio: AudioRecorder())
    }
}
