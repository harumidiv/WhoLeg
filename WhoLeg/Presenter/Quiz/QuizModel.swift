//
//  QuizModel.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import AVFoundation
import Foundation

protocol QuizModel {
    func stringComParison(lhs: String, rhs: String) -> Bool
    func createRandomElement(a: String, b: String, c: String, d: String) -> [String]
    func saveCorrectAnswerData(key: String)
    func correctSoundPlay()
    func mistakeSoundPlay()
}

class QuizModelImpl: QuizModel {
    private let mistakeSound: AVAudioPlayer
    private let correctSound: AVAudioPlayer
    /// AVAudioPlayer の準備や再生はオーディオセッションを待つことがあり、メインスレッドで呼ぶと画面が固まるおそれがあるので専用のキューで行う
    private let soundQueue = DispatchQueue(label: "WhoLeg.QuizModel.sound", qos: .userInitiated)

    init() {
        var path = Bundle.main.path(forResource: "Resource/sound/miss", ofType: "mp3")
        var url = URL(fileURLWithPath: path!)
        do {
            try mistakeSound = AVAudioPlayer(contentsOf: url)
        } catch { fatalError() }

        path = Bundle.main.path(forResource: "Resource/sound/success", ofType: "mp3")
        url = URL(fileURLWithPath: path!)
        do {
            try correctSound = AVAudioPlayer(contentsOf: url)
        } catch { fatalError() }

        soundQueue.async { [mistakeSound, correctSound] in
            mistakeSound.prepareToPlay()
            correctSound.prepareToPlay()
        }
    }

    func correctSoundPlay() {
        soundQueue.async { [correctSound] in
            correctSound.play()
        }
    }

    func mistakeSoundPlay() {
        soundQueue.async { [mistakeSound] in
            mistakeSound.play()
        }
    }

    func saveCorrectAnswerData(key: String) {
        userDefault.set(true, forKey: key)
    }

    func createRandomElement(a: String, b: String, c: String, d: String) -> [String] {
        let arr = [a, b, c, d]
        return arr.shuffled()
    }

    func stringComParison(lhs: String, rhs: String) -> Bool {
        if lhs == rhs {
            return true
        }
        return false
    }
}
