//
//  TabBarView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/18/24.
//

import SwiftUI

struct TabBarView: View {
    
    // sychronized with mainAppView var -> kinda like making it global?
    @AppStorage("selectedTab") var selectedTab: Tab = .kaizen
    
    var body: some View {
    
        VStack {
            Spacer()
            HStack {
                content
            }
            .padding(.vertical, 8)
            .background(
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 9, opaque: true)
                    .background(Color.white.opacity(0.1))
            )
            .mask(RoundedRectangle(cornerRadius: 60, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 60, style: .continuous)
                    .stroke(.white.opacity(0.5), lineWidth: 0.5)
                )
        }
        .padding(.bottom, 10)
    }
    
    var content: some View {
        ForEach(tabItems){ item in
            Button(action: {
                withAnimation(.easeInOut) {
                    selectedTab = item.tab
                }
            }, label: {
                Image(systemName: item.iconName)
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .opacity(selectedTab == item.tab ? 1 : 0.4)
                    .frame(width: 40, height: 40)
                    .background(
                        selectedTab == item.tab ? AnyView(
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 9, opaque: true)
                                .background(Color.white.opacity(0.2))
                        ) : AnyView(EmptyView())
                    )
                    .cornerRadius(30)
                    .padding(.horizontal, 10)
                }
            )
        }
    }
}

#Preview {
    TabBarView()
}


struct TabItem: Identifiable {
    var id = UUID()
    var iconName: String
    var tab: Tab
}

var tabItems = [
    TabItem(iconName: "message", tab: .profile),
    TabItem(iconName: "microbe", tab: .kaizen),
    TabItem(iconName: "gear", tab: .controls)
]

enum Tab: String {
    case profile
    case kaizen
    case controls
}
