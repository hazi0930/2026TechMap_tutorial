//
//  OdoriRoomView.swift
//  CookieMap
//
//  Created by 허지우 on 8/17/26.
//

import SwiftUI
import RealityKit

struct OdoriRoomView: View {
    @Environment(AppState.self)
    private var appState
    
    var body: some View {
        RealityView { content in
            // 1. ARKit 세션부터 실행
            await appState.runSession()
            
            guard appState.isSessionRunning else {
                print("ARKit 세션이 실행되지 않았습니다.")
                return
            }
            
            // 2. 쿠키 불러오고 위치 지정 usdz 파일 배치
            guard let firstcookie = try? await Entity(
                named: "marshmellowcookie",
                in: nil
            ) else {
                print("쿠키를 불러오지 못했다.")
                return
            }
            
            firstcookie.position = [0, 0, -1]
            firstcookie.scale = [0.6, 0.6, 0.6]
            
            content.add(firstcookie)
            
            // 3. 쿠키의 공간좌표 가져오기
            let cookieTransform = firstcookie.transformMatrix(relativeTo: nil)
            
            // 4. 같은 위치에 WorldAnchor 자동생성
            await appState.addWorldAnchor(at: cookieTransform)
        }
        .task {
            await appState.processRoomTrackingUpdates()
        }
        .task {
            await appState.processWorldTrackingUpdates()
        }
        
        
    }
}

#Preview {
    OdoriRoomView()
        .environment(AppState())
}
