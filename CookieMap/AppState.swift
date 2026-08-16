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
    
    // room Tracking 실행
    func runSession() async {
        guard RoomTrackingProvider.isSupported else {
            errorMessage = "Room Tracking 미지원"
            return
        }
        
        do {
            try await session.run([
                roomTracking
            ])
        } catch {
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
    
}


