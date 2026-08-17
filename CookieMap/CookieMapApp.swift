//
//  CookieMapApp.swift
//  CookieMap
//
//  Created by 허지우 on 8/17/26.
//

import SwiftUI

@main
struct CookieMapApp: App {
    @State private var appState = AppState()
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        
        ImmersiveSpace(id: "OdoriRoom") {
            OdoriRoomView()
                .environment(appState)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
