//
//  ScratchSoundPlayer.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import AVFoundation

/// スクラッチを削る「シャリシャリ」音をその場で合成して鳴らす
/// 指を動かす速さに合わせて音量が上がり、止めるとすぐ消える
final class ScratchSoundPlayer {
    static let shared = ScratchSoundPlayer()

    private let engine = AVAudioEngine()
    private let filter = AVAudioUnitEQ(numberOfBands: 2)
    private var sourceNode: AVAudioSourceNode?
    /// オーディオスレッドと共有する音量の目標値と現在値
    private let levels = UnsafeMutablePointer<Float>.allocate(capacity: 2)

    private init() {
        levels.initialize(repeating: 0, count: 2)
    }

    /// 削り始める前に呼んでエンジンを準備する
    func prepare() {
        guard sourceNode == nil else {
            startIfNeeded()
            return
        }
        let format = engine.outputNode.inputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate > 0 ? format.sampleRate : 44_100)
        let levels = self.levels
        var seed: UInt32 = 0x1234_5678
        // 指が止まったら約30ミリ秒で音が消えるように、目標値を毎サンプル減衰させる
        let targetDecay = powf(0.5, 1 / (0.03 * sampleRate))

        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0 ..< Int(frameCount) {
                levels[0] *= targetDecay
                // 音量の変化をなめらかにしてプチプチ音を防ぐ
                levels[1] += (levels[0] - levels[1]) * 0.004

                // xorshiftで軽くノイズを作る
                seed ^= seed << 13
                seed ^= seed >> 17
                seed ^= seed << 5
                let noise = Float(seed) / Float(UInt32.max) * 2 - 1
                // ときどき強い粒を混ぜて、紙をこするようなザラつきを出す
                let grit: Float = (seed & 0x3F) == 0 ? noise * 3 : 0
                let sample = (noise * 0.35 + grit) * levels[1]

                for buffer in buffers {
                    buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = sample
                }
            }
            return noErr
        }
        sourceNode = node

        // 高めの音域だけ残して「シャリシャリ」に近づける
        let highPass = filter.bands[0]
        highPass.filterType = .highPass
        highPass.frequency = 1_200
        highPass.bypass = false
        let presence = filter.bands[1]
        presence.filterType = .parametric
        presence.frequency = 4_200
        presence.bandwidth = 1.2
        presence.gain = 6
        presence.bypass = false

        let monoFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)
        engine.attach(node)
        engine.attach(filter)
        engine.connect(node, to: filter, format: monoFormat)
        engine.connect(filter, to: engine.mainMixerNode, format: monoFormat)
        engine.mainMixerNode.outputVolume = 0.9
        startIfNeeded()
    }

    /// 指を動かすたびに呼ぶ。speedは1秒あたりに動いた距離（pt）
    func scratch(speed: CGFloat) {
        let intensity = Float(min(max(speed / 900, 0.15), 1)) * 0.6
        levels[0] = max(levels[0], intensity)
    }

    /// 削り終わったら呼んでエンジンを止める
    func stop() {
        levels[0] = 0
        // 音がなめらかに消えるのを待ってから止める
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self, self.levels[0] < 0.001 else { return }
            self.engine.pause()
        }
    }

    private func startIfNeeded() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Failed to start scratch sound engine: \(error.localizedDescription)")
        }
    }
}
