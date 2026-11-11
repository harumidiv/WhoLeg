//
//  PopSoundPlayer.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import AVFoundation

/// スプラッシュで足が出てくるときの「ぽぽぽぽぽ」という音をその場で合成して鳴らす
final class PopSoundPlayer {
    static let shared = PopSoundPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    /// オーディオセッションやエンジンの操作はメインスレッドで行うと画面が固まることがあるので、専用のキューで順番に行う。
    /// 以下のプロパティはこのキューの中でだけ触る
    private let queue = DispatchQueue(label: "WhoLeg.PopSoundPlayer", qos: .userInitiated)
    private var isConfigured = false

    private let sampleRate = 44_100.0
    private lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)

    /// 鳴らす前に呼んで、オーディオエンジンを起動しておく。
    /// 鳴らす瞬間に起動すると、そのぶん音が遅れて見た目とずれるため
    func prepare() {
        queue.async { self.startEngineIfNeeded() }
    }

    /// count回の「ぽ」をinterval秒おきに鳴らす。1回ごとに少しずつ音を高くする
    func playPops(count: Int, interval: TimeInterval) {
        guard count > 0 else { return }
        // キューは順番に処理されるので、先に呼んだ prepare() でエンジンが起動したあとに予約される
        queue.async { self.schedulePops(count: count, interval: interval) }
    }

    private func startEngineIfNeeded() {
        guard let format else { return }
        configureIfNeeded(format: format)
        do {
            // ほかのアプリの音楽を止めず、マナーモードのときは鳴らさない
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            if !engine.isRunning {
                try engine.start()
            }
            player.play()
        } catch {
            print("Failed to start pop sound: \(error.localizedDescription)")
        }
    }

    private func schedulePops(count: Int, interval: TimeInterval) {
        let sampleRate = self.sampleRate
        guard let format else { return }

        // 1つのバッファに全部の「ぽ」を並べて書き込み、足が出るタイミングとずれないようにする
        let popDuration = 0.12
        let totalFrames = AVAudioFrameCount((Double(count - 1) * interval + popDuration) * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames),
              let samples = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = totalFrames
        for frame in 0 ..< Int(totalFrames) {
            samples[frame] = 0
        }
        for index in 0 ..< count {
            let start = Int(Double(index) * interval * sampleRate)
            // 何回鳴らしても、最初から最後までちょうど1オクターブ上がるようにする
            let steps = Double(max(count - 1, 1))
            let pitch = pow(2.0, Double(index) / steps)
            writePop(into: samples, start: start, totalFrames: Int(totalFrames), sampleRate: sampleRate, pitch: pitch)
        }

        if !engine.isRunning {
            startEngineIfNeeded()
        }
        guard engine.isRunning else { return }
        // プレイヤーは startEngineIfNeeded() で再生状態にしてあるので、予約した瞬間に鳴り始める
        player.scheduleBuffer(buffer) { [weak self] in
            guard let self else { return }
            self.queue.async {
                self.player.stop()
                self.engine.pause()
            }
        }
    }

    private func configureIfNeeded(format: AVAudioFormat) {
        guard !isConfigured else { return }
        isConfigured = true
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    /// 高い音から低い音へすばやく下がる短い音で「ぽ」を作る
    private func writePop(into samples: UnsafeMutablePointer<Float>, start: Int, totalFrames: Int, sampleRate: Double, pitch: Double) {
        let length = Int(0.12 * sampleRate)
        let startFrequency = 880 * pitch
        let endFrequency = 380 * pitch
        var phase = 0.0
        for i in 0 ..< length {
            let frame = start + i
            guard frame < totalFrames else { break }
            let t = Double(i) / sampleRate
            // 周波数を指数的に下げて、ポンとはじけるような音にする
            let frequency = endFrequency + (startFrequency - endFrequency) * exp(-t / 0.018)
            phase += 2 * .pi * frequency / sampleRate
            let attack = min(t / 0.003, 1)
            let decay = exp(-t / 0.035)
            samples[frame] += Float(sin(phase) * attack * decay * 0.45)
        }
    }
}
