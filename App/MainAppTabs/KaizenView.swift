//
//  KaizenView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/18/24.
//

import SwiftUI
import SiriWaveView

struct KaizenView: View {
    
    @State var vm = ViewModel()
    @State var isSymbolAnimating = false
    
    var body: some View {
                
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "000000"), Color(hex: "#130F40")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack (spacing: 16) {
                    Text("Kaizen")
                        .font(.system(.largeTitle))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    SiriWaveView()
                        .power(power: vm.audioPower)
                        .opacity(vm.siriWaveFormOpacity)
                        .frame(height: 256)
                        .overlay { overlayView }
                    
                    Spacer()
                    
                    switch vm.state {
                    case .recordingSpeech:
                        cancelRecordingButton.offset(y: -75)
                    case .processingSpeech, .playingSpeech:
                        cancelButton.offset(y: -75)
                    default: EmptyView()
                    }

                    
                    if case let .error(error) = vm.state {
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
            .padding()
        }
    }
    
    @ViewBuilder
    var overlayView: some View {
        switch vm.state {
        case .idle, .error:
            startCaptureButton
        case .processingSpeech:
            Image(systemName: "circle")
                .symbolEffect(.bounce.byLayer, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 64))
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        default: EmptyView()
        }
    }
    
    var voicePicker: some View {
        Picker("Selected Voice", selection: $vm.selectedVoice) {
            ForEach(VoiceType.allCases, id: \.self) {
                Text($0.rawValue).id($0)

            }
        }
        .colorMultiply(.white)
        .pickerStyle(.automatic)
        .disabled(!vm.isIdle)
        .padding(.horizontal, 15)
        .padding(.bottom, 100)
    }
    
    var startCaptureButton: some View {
        Button(action: {
            vm.startCaptureAudio()
        }, label: {
            Image(systemName: "circle")
                .foregroundColor(.white)
                .symbolEffect(.pulse.byLayer, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 64))
                .shadow(color: Color.white.opacity(0.5), radius: 4)
                .overlay {
                    Image(systemName: "mic")
                        .imageScale(.medium)
                }
                .padding(.bottom, 51)
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        })
    }
    
    var cancelRecordingButton: some View {
        Button(role: .destructive) {
            vm.cancelRecording()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.red)
                .font(.system(size: 36))
                .padding(.bottom, 15)
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            vm.cancelProcessingTask()
        }, label: {
            Image(systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 36))
                .padding(.bottom, 15)
            
        })
    }
    
}

#Preview("Idle") {
    let vm = ViewModel()
    vm.state = .idle
    return KaizenView(vm: vm)
}


#Preview("Recording Speech"){
    let vm = ViewModel()
    vm.state = .recordingSpeech
    vm.audioPower = 0.1
    return KaizenView(vm: vm)
}

#Preview("Processing Speech"){
    let vm = ViewModel()
    vm.state = .processingSpeech
    return KaizenView(vm: vm)
}

#Preview("Playing Speech"){
    let vm = ViewModel()
    vm.state = .playingSpeech
    vm.audioPower = 0.2
    return KaizenView(vm: vm)
}

#Preview("Error"){
    let vm = ViewModel()
    vm.state = .error("An Error has occured")
    return KaizenView(vm: vm)
}
