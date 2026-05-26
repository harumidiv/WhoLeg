//
//  QuizScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

final class QuizScreenState: ObservableObject {
    @Published var imageName: String = ""
    @Published var choices: [String] = []
    @Published var resultSymbol: String? = nil
    @Published var resultColor: Color = .clear
    @Published var isEnabled: Bool = true
}

struct QuizScreen: View {
    @ObservedObject var state: QuizScreenState
    let onAnswer: (String) -> Void

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                imageArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                optionButtons
                    .padding(.horizontal, 10)
                    .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var imageArea: some View {
        ZStack {
            Image(state.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let symbol = state.resultSymbol {
                Text(symbol)
                    .font(.system(size: 300))
                    .foregroundColor(state.resultColor)
            }
        }
    }

    private var optionButtons: some View {
        VStack(spacing: 20) {
            ForEach(state.choices, id: \.self) { choice in
                Button(choice) {
                    onAnswer(choice)
                }
                .disabled(!state.isEnabled)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(Color(UIColor(hex: "#F4B400")))
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .bold))
                .clipShape(Capsule())
            }
        }
    }
}
