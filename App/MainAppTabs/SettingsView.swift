//
//  SettingsView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/16/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    
    @AppStorage("selectedTab") var tabSelection: Tab = .kaizen
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
      
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "000000"), Color(hex: "#130F40")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
        
                VStack {
                    Text("Settings")
                        .font(.system(.largeTitle))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.white)
                    
                    settingsButtons
                    
                    signOutButton
                    
                    Spacer()
                }
            }
        }
    
    var signOutButton: some View {
        VStack {
            Button(action: {
                do {
                    try viewModel.signOut()
                    showSignInView = true
                    tabSelection = Tab.kaizen // ensures that the app storage sets the default log in to kaizen main everytime
                } catch {
                    print(error)
                }
                
            }, label: {
                Text("Log Out")
                    .secondaryButtonStyle()
                    .padding(.horizontal)
            })
        }
    }
    
    var settingsButtons: some View {
        VStack {
            HStack {
                Image(systemName: "person")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("Account")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.7))
            
            HStack {
                Image(systemName: "bell")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("Notifications")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.7))
            
            HStack {
                Image(systemName: "eye")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("Appearance")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.7))
            
            HStack {
                Image(systemName: "lock")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("Privacy and Security")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.7))
            
            HStack {
                Image(systemName: "beats.headphones")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("Help and Support")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.7))
            
            HStack {
                Image(systemName: "questionmark.circle")
                    .frame(width: 24, height: 55)
                    .padding(.leading, 20)
                Text("About")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
            
        
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .background(Color.black)
        .cornerRadius(10)
        .shadow(color: Color.white.opacity(0.5), radius: 2)
        .padding()
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}
