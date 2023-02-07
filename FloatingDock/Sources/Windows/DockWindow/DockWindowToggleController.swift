//
//  DockWindowToggleController.swift
//  FloatingDock
//
//  Created by Thomas Bonk on 31.01.23.
//  Copyright 2023 Thomas Bonk <thomas@meandmymac.de>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import CoreServices
import Foundation
import SwiftySandboxFileAccess

class DockWindowToggleController: ApplicationLauncher {
    
    // MARK: - Public Static Properties
    
    static var shared: DockWindowToggleController = {
        DockWindowToggleController()
    }()
    
    
    // MARK: - Private Properties
    
    private var dockWindowController: DockWindowController? = nil
    
    
    // MARK: - Initialization
    
    private init() {
        NotificationCenter.default.addObserver(
            forName: .OpenAppNotification,
            object: nil,
            queue: OperationQueue.main,
            using: startApp(notification:))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Public Methods
    
    func toggleDockWindow() {
        if dockWindowController == nil {
            openDockWindow()
        } else {
            closeDockWindow()
        }
    }
    
    
    // MARK: - ApplicationLauncher
    
    func launchApplication(from entry: DockEntry, completion: CompletionHandler? = nil, error: ErrorHandler? = nil) {
        let containingFolderUrl = entry.url!.deletingLastPathComponent()
        let appFilename = entry.url!.lastPathComponent

        SandboxFileAccess
            .shared
            .access(
                fileURL: containingFolderUrl,
                askIfNecessary: true,
                fromWindow: self.dockWindowController?.window,
                persistPermission: true) { result in
                    switch result {
                        case .success(let accessInfo):
                            let appUrl = accessInfo.securityScopedURL?.appendingPathComponent(appFilename)

                            DispatchQueue.main.async {
                                NSWorkspace.shared.openApplication(at: appUrl!, configuration: {
                                    let config = NSWorkspace.OpenConfiguration()
                                    config.activates = true
                                    
                                    return config
                                }()) { app, err in
                                    if let err {
                                        DispatchQueue.main.async {
                                            error?(err)
                                        }
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        completion?()
                                        self.closeDockWindow()
                                    }
                                }
                            }
                            break
                            
                        case .failure(let err):
                            error?(err)
                            break
                    }
                }
    }
    
    
    // MARK: - Private Methods
    
    private func openDockWindow() {
        dockWindowController = DockWindowController()
        dockWindowController?.showWindow(self)
    }
    
    private func closeDockWindow() {
        dockWindowController?.close()
        dockWindowController = nil
    }
    
    private func startApp(notification: Notification) {
        launchApplication(from: notification.object as! DockEntry)
    }
}
