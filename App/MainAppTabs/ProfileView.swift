//
//  ProfileView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/18/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "000000"), Color(hex: "#130F40")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Scan Tool")
                    .font(.system(.title, design: .serif))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ProfileView()
}
