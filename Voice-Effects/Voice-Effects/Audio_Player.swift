//
//  Audio_Player.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI
import AVFoundation

class Audio_Player: NSObject, ObservableObject {
  // MARK: Public properties

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
  var playbackRateIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForRateSelection()
    }
  }
  var playbackPitchIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForPitchSelection()
    }
  }
  var playerProgress: Double = 0 {
    willSet {
      objectWillChange.send()
    }
  }
  var playerTime: PlayerTime = .zero {
    willSet {
      objectWillChange.send()
    }
  }
  var meterLevel: Float = 0 {
    willSet {
      objectWillChange.send()
    }
  }

  let allPlaybackRates: [PlaybackValue] = [
    .init(value: 0.5, label: "0.5x"),
    .init(value: 1, label: "1x"),
    .init(value: 1.25, label: "1.25x"),
    .init(value: 2, label: "2x")
  ]

  let allPlaybackPitches: [PlaybackValue] = [
    .init(value: -0.5, label: "-½"),
    .init(value: 0, label: "0"),
    .init(value: 0.5, label: "+½")
  ]

  // MARK: Private properties

  private let engine = AVAudioEngine()
  private let player = AVAudioPlayerNode()
  private let timeEffect = AVAudioUnitTimePitch()

  private var displayLink: CADisplayLink?

  private var needsFileScheduled = true

  private var audioFile: AVAudioFile?
  private var audioSampleRate: Double = 0
  private var audioLengthSeconds: Double = 0

  private var seekFrame: AVAudioFramePosition = 0
  private var currentPosition: AVAudioFramePosition = 0
  private var audioSeekFrame: AVAudioFramePosition = 0
  private var audioLengthSamples: AVAudioFramePosition = 0

  private var currentFrame: AVAudioFramePosition {
    guard
      let lastRenderTime = player.lastRenderTime,
      let playerTime = player.playerTime(forNodeTime: lastRenderTime)
    else {
      return 0
    }

    return playerTime.sampleTime
  }

  // MARK: - Public

  override init() {
    super.init()

    setupAudio()
    setupDisplayLink()
  }

  func playOrPause() {
//    // 1
//    //This property toggles to the next state which changes the Play/Pause button icon
//    isPlaying.toggle()
//
//    //if the player is currently playing then
//    if player.isPlaying {
//      // 2
//      //the player is paused
//      player.pause()
//    } else {
//      // 3
//      //otherwise the file needs to be scheduled to play
//      if needsFileScheduled {
//        scheduleAudioFile()
//      }
//      player.play()
//    }

    isPlaying.toggle()

    if player.isPlaying {
      displayLink?.isPaused = true
      disconnectVolumeTap()
      
      player.pause()
    } else {
      displayLink?.isPaused = false
      connectVolumeTap()
      
      if needsFileScheduled {
        scheduleAudioFile()
      }
      player.play()
    }
  }

  //Both of the skip buttons in the view call this method. The audio skips ahead by 10 seconds if the forwards parameter is true. In contrast, the audio jumps backward if the parameter is false.
  func skip(forwards: Bool) {
    let timeToSeek: Double

    if forwards {
      timeToSeek = 10
    } else {
      timeToSeek = -10
    }

    seek(to: timeToSeek)
  }

  
  
  // MARK: - Private
//I NEED TO GET THE FILE PATH HERE
  private func setupAudio() {
    // 1
    //gets the URL of the audio file
    guard let fileURL = Bundle.main.url(
      forResource: "keshisong copy",
      withExtension: "mp3")
    else {
      return
    }

    do {
      // 2
      //The audio file is transformed into an AVAudioFile and a few properties are extracted from the file’s metadata
      let file = try AVAudioFile(forReading: fileURL)
      let format = file.processingFormat
      
      audioLengthSamples = file.length
      audioSampleRate = format.sampleRate
      audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
      
      audioFile = file
      
      // 3
      //prepare the audio file for playback
      configureEngine(with: format)
    } catch {
      print("Error reading the audio file: \(error.localizedDescription)")
    }
  }

  private func configureEngine(with format: AVAudioFormat) {
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

  //This schedules the playing of the entire audio file, only once
  //The at: will be the time to play, while nil is to play it immediately
  //
  private func scheduleAudioFile() {
    guard
      let file = audioFile,
      needsFileScheduled
    else {
      return
    }

    needsFileScheduled = false
    seekFrame = 0

    player.scheduleFile(file, at: nil) {
      self.needsFileScheduled = true
    }
  }

  
  
  // MARK: Audio adjustments

  
  private func seek(to time: Double) {
    guard let audioFile = audioFile else {
      return
    }

    // 1
    //Convert time, which is in seconds, to frame position by multiplying it by audioSampleRate, and add it to currentPosition. Then, make sure seekFrame is not before the start of the file nor past the end of the file
    let offset = AVAudioFramePosition(time * audioSampleRate)
    seekFrame = currentPosition + offset
    seekFrame = max(seekFrame, 0)
    seekFrame = min(seekFrame, audioLengthSamples)
    currentPosition = seekFrame

    // 2
    //player.stop() not only stops playback, but also clears all previously scheduled events.
    //Call updateDisplay() to set the UI to the new currentPosition value
    let wasPlaying = player.isPlaying
    player.stop()

    if currentPosition < audioLengthSamples {
      updateDisplay()
      needsFileScheduled = false

      let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
      // 3
      //schedules audio playback at seekframe position in the audio file
      //framecount is the # of framecounts i want to play
      //at:nil so it starts playing immediately
      player.scheduleSegment(
        audioFile,
        startingFrame: seekFrame,
        frameCount: frameCount,
        at: nil
      ) {
        self.needsFileScheduled = true
      }

      // 4
      //If the audio was playing before skip was called, then call player.play() to resume playback.
      if wasPlaying {
        player.play()
      }
    }
  }

  //allows user to change the rate of the audio playback
  private func updateForRateSelection() {
    let selectedRate = allPlaybackRates[playbackRateIndex]
    timeEffect.rate = Float(selectedRate.value)
  }

  //According to the docs for AVAudioUnitTimePitch.pitch, the value is measured in cents. An octave is equal to 1200 cents. The values for allPlaybackPitches, declared at the top of the file, are -0.5, 0, 0.5. Changing the pitch by half an octave keeps the audio intact so you can still hear each word. Feel free to play with this amount to distort the voices more or less.
  //you can change the 1200 (it represents one octave)
  private func updateForPitchSelection() {
    let selectedPitch = allPlaybackPitches[playbackPitchIndex]
    timeEffect.pitch = 1200 * Float(selectedPitch.value)
  }

  
  
  
  // MARK: Audio metering

  //The average power of the playing audio determines the height of the view
  //You’ll compute the average power on a 1k buffer of audio samples. A common way to determine the average power of a buffer of audio samples is to calculate the Root Mean Square (RMS) of the samples.
  //Average power is the representation, in decibels, of the average value of a range of audio sample data. You should also be aware of peak power, which is the max value in a range of sample data.
  private func scaledPower(power: Float) -> Float {
    // 1
    //makes sure that the power is a valid value (i think that guard is like a safety check in swift)
    guard power.isFinite else {
      return 0.0
    }

    let minDb: Float = -80

    // 2
    //sets the dynamic range of the VU meter to be 80 decibels
    //any value below -80.0 dB return 0
    if power < minDb {
      return 0.0
    } else if power >= 1.0 {
      return 1.0
    } else {
      // 3
      //compute scaled power
      return (abs(minDb) - abs(power)) / abs(minDb)
    }
  }

  private func connectVolumeTap() {
    // 1
    //get data in the form of main Mixer Node's output
    let format = engine.mainMixerNode.outputFormat(forBus: 0)
    // 2
    //this method gives access to the output of mainMixerNode
    //to get the actual buffer size, since this does not give you it, you can compute buffer.frameLength
    engine.mainMixerNode.installTap(
      onBus: 0,
      bufferSize: 1024,
      format: format
    ) { buffer, _ in
      // 3
      //buffer.floatChannelData gives you an array of pointers to each sample’s data. channelDataValue is an array of UnsafeMutablePointer<Float>.
      guard let channelData = buffer.floatChannelData else {
        return
      }
      
      let channelDataValue = channelData.pointee
      // 4
      //Converting from an array of UnsafeMutablePointer<Float> to an array of Float makes later calculations easier. To do that, use stride(from:to:by:) to create an array of indexes into channelDataValue. Then, map{ channelDataValue[$0] } to access and store the data values in channelDataValueArray
      let channelDataValueArray = stride(
        from: 0,
        to: Int(buffer.frameLength),
        by: buffer.stride)
        .map { channelDataValue[$0] }
      
      // 5
      //Computing the power with Root Mean Square involves a map/reduce/divide operation. First, the map operation squares all the values in the array, which the reduce operation sums. Divide the sum of the squares by the buffer size, then take the square root, producing the RMS of the audio sample data in the buffer. This should be a value between 0.0 and 1.0, but there could be some edge cases where it’s a negative value.
      let rms = sqrt(channelDataValueArray.map {
        return $0 * $0
      }
      .reduce(0, +) / Float(buffer.frameLength))
      
      // 6
      //Convert the RMS to decibels. Here’s an acoustic decibel reference, if you need it. The decibel value should be between -160 and 0, but if RMS is negative, this decibel value would be NaN
      let avgPower = 20 * log10(rms)
      // 7
      //Scale the decibels into a value suitable for your VU meter
      let meterLevel = self.scaledPower(power: avgPower)

      DispatchQueue.main.async {
        self.meterLevel = self.isPlaying ? meterLevel : 0
      }
    }

  }

  //AVAudioEngine allows only a single tap per bus. It’s a good practice to remove it when not in use
  private func disconnectVolumeTap() {
    engine.mainMixerNode.removeTap(onBus: 0)
    meterLevel = 0
  }

  // MARK: Display updates

  
  //CADisplayLink is a timer object that synchronizes with the display’s refresh rate
  private func setupDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
    displayLink?.add(to: .current, forMode: .default)
    displayLink?.isPaused = true
  }

  //update the display of the time change
  //Stop the player.
  //Reset the seek and current position properties.
  //Pause the display link and reset isPlaying.
  //Disconnect the volume tap.
  @objc private func updateDisplay() {
    // 1
    //The property seekFrame is an offset, which is initially set to zero, added to or subtracted from currentFrame. Make sure currentPosition doesn’t fall outside the range of the file.
    currentPosition = currentFrame + seekFrame
    currentPosition = max(currentPosition, 0)
    currentPosition = min(currentPosition, audioLengthSamples)

    // 2
    //if the current position is greater that the length of the audio/meaning it is at the end
    if currentPosition >= audioLengthSamples {
      player.stop()
      
      seekFrame = 0
      currentPosition = 0
      
      isPlaying = false
      displayLink?.isPaused = true
      
      disconnectVolumeTap()
    }

    // 3
    //get the elapsed time and remaining time using current position
    //player time = a struct that takes the two progress values as input
    playerProgress = Double(currentPosition) / Double(audioLengthSamples)

    let time = Double(currentPosition) / audioSampleRate
    playerTime = PlayerTime(
      elapsedTime: time,
      remainingTime: audioLengthSeconds - time
    )
  }
}
