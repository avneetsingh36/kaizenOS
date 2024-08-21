//
//  RootView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/16/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            MainAppView(showSignInView: $showSignInView)
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil ? true : false
        }
        .fullScreenCover(isPresented: $showSignInView){
            HomePageView(showSignInView: $showSignInView)
            
        }
    }
}

#Preview {
    RootView()
}
