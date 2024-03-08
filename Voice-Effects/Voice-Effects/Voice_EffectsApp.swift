//
//  Voice_EffectsApp.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("avaudioerror")
        }
        return true
    }
}

@main
struct Voice_EffectsApp: App {
    
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
