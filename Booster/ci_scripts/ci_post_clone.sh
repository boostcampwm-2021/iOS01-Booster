#!/bin/sh

#  ci_post_clone.sh
#  Booster
#
#  Created by Hani on 2022/01/06.
#

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install
