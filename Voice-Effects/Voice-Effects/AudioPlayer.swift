//
//  Audio_Player.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import AVFoundation
import SwiftUI
import AVFAudio

class AudioPlayer: NSObject, ObservableObject {
    
    var isPlaying = false {
      willSet {
        withAnimation {
          objectWillChange.send()
        }
      }
    }
    var isPlayerReady = false {
      willSet {
        objectWillChange.send()
      }
    }
    private var displayLink: CADisplayLink?
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let timeEffect = AVAudioUnitTimePitch()
    var audioFile: AVAudioFile?
    
    
    var recordedAudioURL:URL!
    //var audioFile:AVAudioFile!
   // var audioEngine:AVAudioEngine?
    //var audioPlayerNode: AVAudioPlayerNode?
    
    var audioPlayer: AVAudioPlayer?
    

    private var needsFileScheduled = true
    
    
    override init() {
      super.init()
        
      setupAudio()
    }
    
    // MARK: Audio Functions
    
    func setupAudio() {
      // 1
      //gets the URL of the audio file
      guard let fileURL = Bundle.main.url(
        forResource: "music copy",
        withExtension: ".wav")
      else {
        return
      }

      do {
        // 2
        //The audio file is transformed into an AVAudioFile and a few properties are extracted from the file’s metadata
        let file = try AVAudioFile(forReading: fileURL)
        //let format = file.processingFormat

        audioFile = file
        
        // 3
        //prepare the audio file for playback
//        configureEngine(with: format)
          
          
      } catch {
        print("Error reading the audio file: \(error.localizedDescription)")
      }
    }
    
    func playOrPause() {

      isPlaying.toggle()

      if player.isPlaying {
        displayLink?.isPaused = true

        
        player.pause()
      } else {
        displayLink?.isPaused = false

        
        if needsFileScheduled {
          scheduleAudioFile()
        }
        player.play()
      }
    }

    
    
    
    func configureEngine(with format: AVAudioFormat) {
      // 1
      //Attaches the player node to the engine.
      //These nodes will either produce, process or output audio
      //
      engine.attach(player)
      engine.attach(timeEffect)

      // 2
      //Connect the player and time effect to the engine. prepare() preallocates needed resources
      engine.connect(
        player,
        to: timeEffect,
        format: format)
      engine.connect(
        timeEffect,
        to: engine.mainMixerNode,
        format: format)
      //prepare() function
      engine.prepare()

      do {
        // 3
        //Start the engine, which prepares the device to play audio. The state is also updated to prepare the visual interface
        try engine.start()
        
        scheduleAudioFile()
        isPlayerReady = true
      } catch {
        print("Error starting the player: \(error.localizedDescription)")
      }
    }
    
    
    func scheduleAudioFile() {
      guard
        let file = audioFile,
        needsFileScheduled
      else {
        return
      }

      needsFileScheduled = false

      player.scheduleFile(file, at: nil) {
        self.needsFileScheduled = true
      }
    }
    

    // Mark: Play Sound
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false, vader: Bool = false) {
        playOrPause()
        // initialize audio engine components
        //let audioEngine = AVAudioEngine()
        
        // node for playing audio
        //let audioPlayerNode = AVAudioPlayerNode()
        //engine.attach(player)
        
        // node for adjusting rate/pitch
        
        engine.attach(player)
        
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
//        engine.connect(
//          player,
//          to: timeEffect,
//          format: format)
//        engine.connect(
//          timeEffect,
//          to: engine.mainMixerNode,
//          format: format)
//        //prepare() function
//        engine.prepare()
        engine.attach(changeRatePitchNode)
        
        engine.prepare()
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        engine.attach(echoNode)
        
        engine.prepare()
        
        let reverbNode = AVAudioUnitReverb()
        if vader {
            // node for reverb
            reverbNode.loadFactoryPreset(.mediumHall)
            reverbNode.wetDryMix = 16
            engine.attach(reverbNode)
            
            engine.prepare()
        } else {
            // node for reverb
            reverbNode.loadFactoryPreset(.cathedral)
            reverbNode.wetDryMix = 50
            engine.attach(reverbNode)
            engine.prepare()
        }
        
        
//        // connect nodes
//        if echo == true && reverb == true {
//            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
//        } else if echo == true {
//            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
//        } else if reverb == true {
//            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
//        } else {
//            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
//        }
        
        // schedule to play and start the engine!
         player.stop()
        //playOrPause()
//        audioPlayerNode.scheduleFile(audioFile, at: nil) {
//
//            var delayInSeconds: Double = 0
//
//            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
//
//                if let rate = rate {
//                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
//                } else {
//                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
//                }
//            }
//
//            // schedule a stop timer for when audio finishes playing
//            //self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
//           // RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
//        }
        
        do {
            try engine.start()
        } catch {
            print("error")
            return
        }
        
        // play the recording!
        player.play()
        //playOrPause()
    }

    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            engine.connect(nodes[x], to: nodes[x+1], format: audioFile!.processingFormat)
        }
    }
}

