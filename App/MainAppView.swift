//
//  MainAppView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/17/24.
//

import SwiftUI

struct MainAppView: View {
    
    @AppStorage("selectedTab") var tabSelection: Tab = .kaizen
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            VStack {
                
                switch tabSelection {
                case .profile:
                    ProfileView()
                case .kaizen:
                    KaizenView()
                case .controls:
                    SettingsView(showSignInView: $showSignInView)
                }
            }
            
            TabBarView()

        }
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    MainAppView(showSignInView: .constant(false))
}
