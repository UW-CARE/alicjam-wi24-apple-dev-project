//
//  AudioStatus.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/6/24.
//

import Foundation

enum AudioStatus: Int, CustomStringConvertible {

  case stopped,
       playing,
       recording

  var audioName: String {
    let audioNames = ["Audio:Stopped", "Audio:Playing", "Audio:Recording"]
    return audioNames[rawValue]
  }

  var description: String {
    return audioName
  }


}
