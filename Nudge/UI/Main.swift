//
//  Main.swift
//  Nudge
//
//  Created by Erik Gomez on 2/2/21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // Thanks you ftiff
    // Create an AppDelegate so the close button will terminate Nudge
    // Technically not needed because we are now hiding those buttons
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    // Disable CMD+Q - Only exit if primaryQuitButton is clicked
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if shouldExit {
            return NSApplication.TerminateReply.terminateNow
        } else {
            return NSApplication.TerminateReply.terminateCancel
        }
    }

    func runSoftwareUpdate() {
        // Temporary workaround for Big Sur bug
        let msg = "Due to a bug in Big Sur, Nudge cannot reliably use /usr/sbin/softwareupdate to download updates. See https://openradar.appspot.com/radar?id=4987491098558464 for more information and if you are impacted, duplicate this issue."
        softwareupdateDownloadLog.warning("\(msg, privacy: .public)")
        return

        if asyncronousSoftwareUpdate {
            DispatchQueue(label: "nudge-su", attributes: .concurrent).asyncAfter(deadline: .now(), execute: {
                SoftwareUpdate().Download()
            })
        } else {
            SoftwareUpdate().Download()
        }
    }

    // Random Delay logic
    func applicationWillFinishLaunching(_ notification: Notification) {
        if randomDelay {
            let randomDelaySeconds = Int.random(in: 1...maxRandomDelayInSeconds)
            uiLog.notice("Delaying initial run (in seconds) by: \(String(randomDelaySeconds), privacy: .public)")
            sleep(UInt32(randomDelaySeconds))
        }
        self.runSoftwareUpdate()
    }
}

@main
struct Main: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let manager = try! PolicyManager() // TODO: handle errors
    var body: some Scene {
        #if DEBUG
        WindowGroup {
            VSplitView {
                ContentView(simpleModePreview: false).environmentObject(manager)
                    .onAppear(perform: nudgeStartLogic)
                    .frame(width: 900, height: 450)
                ContentView(simpleModePreview: true).environmentObject(manager)
                    .onAppear(perform: nudgeStartLogic)
                    .frame(width: 900, height: 450)
            }
            .frame(height: 900)
        }
        // Hide Title Bar
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif

        WindowGroup {
            ContentView(simpleModePreview: false).environmentObject(manager)
                .onAppear(perform: nudgeStartLogic)
                .frame(width: 900, height: 450)
        }
        // Hide Title Bar
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
