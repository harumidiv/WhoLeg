//
//  ResultScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/05/26.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI

struct ResultScreen: View {
    let score: Int

    var body: some View {
        if score == 10 {
            goodView
        } else if score > 5 {
            normalView
        } else {
            badView
        }
    }

    // MARK: - Good (score == 10)

    private var goodView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color(red: 1, green: 0.485, blue: 0.226)
                    .ignoresSafeArea()

                Text("全問正解!!")
                    .font(.system(size: 70, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, geometry.safeAreaInsets.top + 32)

                VStack {
                    Spacer()
                    Image("white2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geometry.size.height * 0.70)
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Normal (score > 5)

    private var normalView: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0, green: 1, blue: 0.332)
                    .ignoresSafeArea()

                HStack(spacing: 0) {
                    Image("white")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width * 0.70,
                            height: geometry.size.height * 0.80
                        )

                    Spacer()

                    Text("\(score)/10\nまずまずだね")
                        .font(.system(size: 35))
                        .foregroundStyle(Color(red: 0.937, green: 0.937, blue: 0.957))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 16)
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Bad (score <= 5)

    private var badView: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0, green: 0.510, blue: 0.392)
                    .ignoresSafeArea()

                HStack(alignment: .center, spacing: 0) {
                    Text("\(score)/10\nうーん...")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.leading, 16)

                    Spacer()
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("black")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: geometry.size.width * 0.50,
                                height: geometry.size.height * 0.50
                            )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview("Good") {
    ResultScreen(score: 10)
}

#Preview("Normal") {
    ResultScreen(score: 7)
}

#Preview("Bad") {
    ResultScreen(score: 3)
}
