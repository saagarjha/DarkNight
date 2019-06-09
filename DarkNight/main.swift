//
//  main.swift
//  DarkNight
//
//  Created by Saagar Jha on 6/5/18.
//  Copyright © 2018 Saagar Jha. All rights reserved.
//

import AppKit

let defaults = UserDefaults(suiteName: "com.saagarjha.DarkNight")
// Create an application
_ = NSApplication.shared

func appearanceChanged() {
	let task = Process()
	task.launchPath = defaults?.string(forKey: "command") ?? "/usr/local/bin/dark-night"
	let theme = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
	task.arguments = theme == .darkAqua ? ["enabled"] : []
	task.launch()
	task.waitUntilExit()
	// For compatibility with applications using this method of detection
	CFPreferencesSetValue("AppleInterfaceStyle" as CFString, theme == .darkAqua ? "Dark" as CFPropertyList : nil, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
	CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
	DistributedNotificationCenter.default().post(name: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
}

let observation = NSApp.observe(\.effectiveAppearance, options: [.old, .new]) { _, change in
	if change.oldValue != change.newValue {
		appearanceChanged()
	}
}

// Set the initial state
appearanceChanged()

NSApp.run()
