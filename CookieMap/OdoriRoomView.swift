//
//  OdoriRoomView.swift
//  CookieMap
//
//  Created by 허지우 on 8/17/26.
//

import SwiftUI
import RealityKit

struct OdoriRoomView: View {
    var body: some View {
        RealityView { content in
            // usdz 파일 배치
            guard let firstcookie = try? await Entity(
                named: "marshmellowcookie",
                in: nil
            ) else {
                print("쿠키를 불러오지 못했다")
                return
            }
            
            firstcookie.position = [0, 0, 0]
            firstcookie.scale = [0.6, 0.6, 0.6]
            
            content.add(firstcookie)
        }
        
        
    }
}

#Preview {
    OdoriRoomView()
}
