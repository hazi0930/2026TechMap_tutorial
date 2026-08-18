//
//  AppState.swift
//  CookieMap
//
//  Created by 허지우 on 8/17/26.
//

import SwiftUI
import ARKit
import RealityKit

@MainActor
@Observable
class AppState {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    private let roomTracking = RoomTrackingProvider()
    
    private var roomAnchors: [UUID: RoomAnchor] = [:]
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    private var cookieEntities: [UUID: Entity] = [:]
    
    var currentRoomID: UUID?
    var errorMessage: String?
    
    private(set) var isSessionRunning = false
    
    // room Tracking 실행
    func runSession() async {
        if isSessionRunning {
            return
        }
        
        guard RoomTrackingProvider.isSupported,
        WorldTrackingProvider.isSupported else {
            errorMessage = "Room Tracking or World Tracking 미지원"
            return
        }
        
        do {
            try await session.run([
                worldTracking,
                roomTracking
            ])
            
            isSessionRunning = true
            print("ARKit 세션 실행 완료")
        } catch {
            isSessionRunning = false
            errorMessage = error.localizedDescription
        }
    }
    
    // 현재 방 변화를 감지
    func processRoomTrackingUpdates() async {
    for await update in roomTracking.anchorUpdates {
        let roomAnchor = update.anchor
        
        switch update.event {
        case .added, .updated:
            if roomAnchor.isCurrentRoom {
                currentRoomID = roomAnchor.id
                print("현재 방: ",roomAnchor.id)
            }
            
        case .removed:
            if currentRoomID == roomAnchor.id {
                currentRoomID = nil
            }
        }
        }
    }
    
    // 현실 공간에 WorldAnchor 추가
    func addWorldAnchor(
        at transform: simd_float4x4
    ) async {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: transform)
        
        do {
            try await worldTracking.addAnchor(worldAnchor)
            
            print("WorldAnchor 추가 요청 성공:", worldAnchor.id)
        } catch {
            errorMessage = error.localizedDescription
            print("WorldAnchor 추가 실패:", error)
        }
    }
    
    // WorldAnchor 업데이트 처리
    func processWorldTrackingUpdates() async {
        for await update in worldTracking.anchorUpdates {
            let worldAnchor = update.anchor

            switch update.event {
            case .added:
                print("WorldAnchor 추가:", worldAnchor.id)

            case .updated:
                print("WorldAnchor 업데이트:", worldAnchor.id)

            case .removed:
                print("WorldAnchor 제거:", worldAnchor.id)
            }
        }
    }
    
    // 쿠키 업데이트 이용 가능?
    private func updateCookieVisibility() {
        guard let currentRoom =
                roomTracking.currentRoomAnchor else {
            // 현재 방을 감지하지 못하면 모든 쿠키 숨김
            for cookie in cookieEntities.values {
                cookie.isEnabled = false
            }

            return
        }

        for (anchorID, worldAnchor) in worldAnchors {
            let translation = worldAnchor
                .originFromAnchorTransform
                .columns.3

            let position = SIMD3<Float>(
                translation.x,
                translation.y,
                translation.z
            )

            let isInCurrentRoom =
                currentRoom.contains(position)

            cookieEntities[anchorID]?
                .isEnabled = isInCurrentRoom
        }
    }
}


