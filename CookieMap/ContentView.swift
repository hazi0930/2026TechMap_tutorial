//
//  ContentView.swift
//  CookieMap
//
//  Created by 허지우 on 8/17/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var isCookieMap = false
    
    var body: some View {
        VStack {
            Text("CookieMap 입장")
                .font(.extraLargeTitle)
            
            Button(isCookieMap ? "CookieMap 퇴장하기" : "CookieMap 입장하기") {
                Task { await toggleCookieMap() }
            }
            if let currentRoomID = appState.currentRoomID {
                Text("현재 방 감지됨")
                
                Text(currentRoomID.uuidString)
            } else {
                Text("방 감지 대기중")
            }
        }
        .padding()
    }
    
    
    private func toggleCookieMap() async {
        if isCookieMap {
            // 퇴장해야 한다
            await dismissImmersiveSpace()
            isCookieMap = false
        } else {
            // 입장해야 한다
            switch await openImmersiveSpace(id: "OdoriRoom") {
            case .opened:
                isCookieMap = true
            case .userCancelled, .error:
                isCookieMap = false
            @unknown default:
                isCookieMap = false
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppState())
}
