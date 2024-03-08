//
//  Home_View.swift
//  Voice-Effects
//
//  Created by Alicja Misiuda on 3/5/24.
//

import SwiftUI

struct Home_View: View {
    var body: some View {
        
        Text(" Voice Effects")
            .font(.system(size: 80, design: .rounded))
            .foregroundStyle(LinearGradient(
                colors: [.black, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
        )
            .padding(.top, 90)
        Spacer()
    }
}

#Preview {
    Home_View()
}
