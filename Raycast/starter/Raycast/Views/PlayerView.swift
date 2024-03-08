/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct PlayerView: View {
  @StateObject var viewModel = PlayerViewModel()

  var body: some View {
    VStack {
      Image.artwork
        .resizable()
        .aspectRatio(
          nil,
          contentMode: .fit)
        .padding()
        .layoutPriority(1)

      controlsView
        .padding(.bottom)
    }
  }

  private var controlsView: some View {
    VStack {
      ProgressView(value: viewModel.playerProgress)
        .progressViewStyle(
          LinearProgressViewStyle(tint: .rwGreen))
        .padding(.bottom, 8)

      HStack {
        Text(viewModel.playerTime.elapsedText)

        Spacer()

        Text(viewModel.playerTime.remainingText)
      }
      .font(.system(size: 14, weight: .semibold))

      Spacer()

      audioControlButtons
        .disabled(!viewModel.isPlayerReady)
        .padding(.bottom)

      Spacer()

      adjustmentControlsView
    }
    .padding(.horizontal)
  }

  private var adjustmentControlsView: some View {
    VStack {
      HStack {
        Text("Playback speed")
          .font(.system(size: 16, weight: .bold))

        Spacer()
      }

      Picker("Select a rate", selection: $viewModel.playbackRateIndex) {
        ForEach(0..<viewModel.allPlaybackRates.count) {
          Text(viewModel.allPlaybackRates[$0].label)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .disabled(!viewModel.isPlayerReady)
      .padding(.bottom, 20)

      HStack {
        Text("Pitch adjustment")
          .font(.system(size: 16, weight: .bold))

        Spacer()
      }

      Picker("Select a pitch", selection: $viewModel.playbackPitchIndex) {
        ForEach(0..<viewModel.allPlaybackPitches.count) {
          Text(viewModel.allPlaybackPitches[$0].label)
          
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .disabled(!viewModel.isPlayerReady)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 5)
        .fill(Color.groupedBackground))
  }

  private var audioControlButtons: some View {
    HStack(spacing: 20) {
      Spacer()

      Button {
        viewModel.skip(forwards: false)
      } label: {
        Image.backward
      }
      .font(.system(size: 32))

      Spacer()

      Button {
        viewModel.playOrPause()
      } label: {
        ZStack {
          Color.rwGreen
            .frame(
              width: 10,
              height: 35 * CGFloat(viewModel.meterLevel))
            .opacity(0.5)

          viewModel.isPlaying ? Image.pause : Image.play
        }
      }
      .frame(width: 40)
      .font(.system(size: 45))

      Spacer()

      Button {
        viewModel.skip(forwards: true)
      } label: {
        Image.forward
      }
      .font(.system(size: 32))

      Spacer()
    }
    .foregroundColor(.primary)
    .padding(.vertical, 20)
    .frame(height: 58)
  }
}

struct PlayerView_Previews: PreviewProvider {
  static var previews: some View {
    PlayerView(viewModel: PlayerViewModel())
  }
}
