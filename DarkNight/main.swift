//
//  main.swift
//  DarkNight
//
//  Created by Saagar Jha on 6/5/18.
//  Copyright © 2018 Saagar Jha. All rights reserved.
//

import Foundation

let skylight = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/Skylight", RTLD_LAZY)
let SLSGetAppearanceThemeLegacy = unsafeBitCast(dlsym(skylight, "SLSGetAppearanceThemeLegacy"), to: (@convention (c) () -> Bool).self)
let SLSSetAppearanceThemeLegacy = unsafeBitCast(dlsym(skylight, "SLSSetAppearanceThemeLegacy"), to: (@convention (c) (Bool) -> Void).self)
let coreBrightness = dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_LAZY)

@objc protocol CBBlueLightClientProtocol {
	init()
	func setStatusNotificationBlock(_ block: @escaping @convention(block) (UnsafePointer<ObjCBool>) -> Void)
	func getBlueLightStatus(_ pointer: UnsafePointer<ObjCBool>)
}

let CBBlueLightClient: CBBlueLightClientProtocol.Type! = {
	return unsafeBitCast(NSClassFromString("CBBlueLightClient"), to: CBBlueLightClientProtocol.Type?.self)
}()

let blueLightClient = CBBlueLightClient.init()

let nightShiftHandler: @convention(block) (UnsafePointer<ObjCBool>) -> Void = { pointer in
	// struct status { BOOL active, BOOL enabled, ...
	SLSSetAppearanceThemeLegacy(pointer[1].boolValue)
}

blueLightClient.setStatusNotificationBlock(nightShiftHandler)

DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: OperationQueue.main) { notification in
	let task = Process()
	task.launchPath = "/usr/local/bin/night-shift"
	task.arguments = SLSGetAppearanceThemeLegacy() ? ["enabled"] : []
	task.launch()
	task.waitUntilExit()
}

// Set the initial state
let buffer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 100)
blueLightClient.getBlueLightStatus(buffer)
nightShiftHandler(buffer)
buffer.deallocate()

RunLoop.main.run()
