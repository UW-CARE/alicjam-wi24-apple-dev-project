//
//  AudioRecorder.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
class AudioRecorder: ObservableObject {
    // initializing variables
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder!
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set new recording session")
        }
        
        // Creates a date formatter for naming the file
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        // retrieves the URL for the document directory in the user's domain, which can be used for tasks such as saving or retrieving files specific to the application.
//        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // creates a file path for an audio recording.
//        let audioFileName = docPath.appendingPathComponent("\(dateFormatter.string(from: Date())) Record.m4a")
        
        
        let audioFileName = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        // settings for what the app will record (format, sample rate, quality, etc.)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recording = true
        } catch {
            print("Couldn't start recording.")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        recording = false
        audioRecorder = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
