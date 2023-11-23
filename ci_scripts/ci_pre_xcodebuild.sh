#!/bin/sh

# Steps:
# 1. Read CUSTOM_MARKETING_VERSION from Info-plist file
customMarketingVersion=`/usr/libexec/PlistBuddy -c 'Print :CUSTOM_MARKETING_VERSION' FloatingDock/Info.plist`
# 2. Calculate version: ${CUSTOM_MARKETING_VERSION}.0.${BUILD_NUMBER}
version="${customMarketingVersion}.0.${BUILD_NUMBER}"
# 3. Set CFBundleShortVersionString in Info.plist to calculated version
/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString ${version}' FloatingDock/Info.plist
