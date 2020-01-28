#!/bin/sh

#  main.sh
#  WhoLeg
#
#  Created by 佐川 晴海 on 2020/01/25.
#  Copyright © 2020 佐川晴海. All rights reserved.

swift_code() {
QUIZ_INFO=./WhoLeg/Domain/QuizInfo.swift
VALIDATE_JSON=./Script/ValidateJson/ValidateJson.swift

cat ${QUIZ_INFO} ${VALIDATE_JSON}
}
echo "$(swift_code)" \
| DEVELOPER_DIR="$DEVELOPER_DIR" \
xcrun --sdk macosx \
"$TOOLCHAIN_DIR/usr/bin/"swift -F "$SRCROOT/Carthage/Build/Mac/" -
