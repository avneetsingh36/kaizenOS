import AVFoundation
import Foundation
import Observation
import XCAOpenAIClient
import EventKit


@Observable
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private var calendarManager = CalendarManager()

    // Must Append your key HERE
    let client = OpenAIClient(apiKey: "put your key here")
 
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordingSession = AVAudioSession.sharedInstance()
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var audioPower = 0.0
    var prevAudioPower: Double?
    
    var processingSpeechTask: Task<Void, Never>?
    
    var selectedVoice = VoiceType.alloy
    
    var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recording.m4a")
    }
    
    var conversationHistoryFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("conversationHistory.json")
    }
    
    var state = VoiceChatState.idle {
        didSet { print(state) }
    }
    
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    // wave view is only present when recording or playing speech
    var siriWaveFormOpacity: CGFloat {
        switch state {
        case .recordingSpeech, .playingSpeech: return 1
        default: return 0
        }
    }
    
    // Conversation history storage
    var conversationHistory: [String] = [] {
        didSet {
            saveConversationHistory()
        }
    }
    
    // Maximum number of messages in the conversation history (3 user + 3 Kaizen + 1 context)
    let maxHistoryCount = 7
    
    // Initial context for the assistant
    let initialContext: String
  
    override init() {
        
        let now = Date()
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: now)
        
        // Format the time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        timeFormatter.dateStyle = .none
        let formattedTime = timeFormatter.string(from: now)
        
        initialContext = """
        Today Date: \(formattedDate)
        Current Time: \(formattedTime)
        
        Context: Your Name is Kaizen and you are a helpful AI assitant that can currently add tasks to ones calendar. Any function calls that are ready to be addressed should be added at the end of a response "Function Call: samplefunction(var 1, var 2)". If you feel like a user is trying to do this make sure that you get all the needed variables and ONLY when you do have enough to append the function call, append the functio call to the end of the response because it will run.
        
        Calendar Function Call: addEvent(title: String, startYear: Int, startMonth: Int, startDay: Int, startHour: Int, endYear: Int, endMonth: Int, endDay: Int, endHour: Int)
            - when you make a function call, the meeting is done already, so just let the user know and dont confirm, you should NEVER have the funciton call and confirm because then it double books the meeting
            - make sure that the end time is always after the start time
        """

        
        super.init()
        loadConversationHistory()
        #if !os(macOS)
        do {
            #if os(iOS)
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            #else
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            #endif
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self ]allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user.")
                }
                
            }
        } catch {
            state = .error(error)
        }
        #endif
    }
    
    func startCaptureAudio() {
        resetValues()
        state = .recordingSpeech
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL,
                                                settings: [
                                                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                    AVSampleRateKey: 12000,
                                                    AVNumberOfChannelsKey: 1,
                                                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                                ])
        
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            // updates the waveform for the vocal input
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else {return}
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) )) // normalizing eq for vocal decibles to audio waves
                self.audioPower = power
            })
            
            // this section helps kaizen know when user is done speaking (withTimeInterval contols how long it waits for input)
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self]_ in
                guard self.audioRecorder != nil else {return}
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) )) // normalizing eq for vocal decibles to audio waves
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                
                // helps us stop recording
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.40 && power < 0.25 {
                    self.finishCaptureAudio()
                    return
                }
                
                self.prevAudioPower = power //keeps updating the power
            })
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func finishCaptureAudio() {
        resetValues()
        
        do {
            let data = try Data(contentsOf: captureURL)
            processingSpeechTask = processSpeechTask(audioData: data) // have a var with the task of audio inside
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    // Chat GPT only used from processing
    func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                // prompt parsed in GPT
                self.state = .processingSpeech
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                
                // Update conversation history
                updateConversationHistory(with: "User: \(prompt)")
                
                // Full prompt including initial context and conversation history
                let fullPrompt = "\(initialContext)\n\n\(conversationHistory.joined(separator: "\n"))"
                
                // response from GPT
                try Task.checkCancellation()
                var responseText = try await client.promptChatGPT(prompt: fullPrompt)
                
                print("____________________")
                
                print("REAL RESPONSE: \(responseText)")
                
                print("____________________")
                
                // Parse out duplicate "Kaizen:" if present
                if responseText.contains("Kaizen:") {
                    responseText = responseText.replacingOccurrences(of: "Kaizen:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
    
                // Handle function call in response text
                handleFunctionCall(in: &responseText)
                
                
                // Update conversation history with response
                updateConversationHistory(with: "Kaizen: \(responseText)")
                
                // Print conversation history
                print("Updated Conversation History:\n\(initialContext)\n\n\(conversationHistory.joined(separator: "\n"))")
                
                // response in audio format retrieved
                try Task.checkCancellation()
                let data = try await client.generateSpeechFrom(input: responseText, voice: .init(rawValue: selectedVoice.rawValue) ?? .alloy)
                
                // play audio data locally
                try Task.checkCancellation()
                try self.playAudio(data: data)
                
            } catch {
                if Task.isCancelled { return } // if task is cancelled by user
                state = .error(error)
                resetValues()
            }
        }
    }
    
    func playAudio(data: Data) throws {
        self.state = .playingSpeech
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()
        
        // updates the waveform for output audio
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self]_ in
            guard self.audioPlayer != nil else {return}
            self.audioPlayer.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioPlayer.averagePower(forChannel: 0)) / 160) )) // normalizing eq for vocal decibles to audio waves
            self.audioPower = power
        })
    }
    
    // Ensure the state goes back to idle after audio finishes playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetValues()
        state = .idle
    }
    
    func updateConversationHistory(with newMessage: String) {
        conversationHistory.append(newMessage)
        if conversationHistory.count > maxHistoryCount {
            conversationHistory = Array(conversationHistory.dropFirst(2)) // Drop one user and one Kaizen message to maintain conversation context
        }
    }
    
    func saveConversationHistory() {
        do {
            let data = try JSONEncoder().encode(conversationHistory)
            try data.write(to: conversationHistoryFileURL)
        } catch {
            print("Failed to save conversation history: \(error)")
        }
    }
    
    func loadConversationHistory() {
        do {
            let data = try Data(contentsOf: conversationHistoryFileURL)
            conversationHistory = try JSONDecoder().decode([String].self, from: data)
        } catch {
            print("Failed to load conversation history: \(error)")
        }
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func resetValues () {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
    private func handleFunctionCall(in responseText: inout String) {
        // Check for function call in the response and remove it from the text to be read out
        let functionCallMarker = "function call:"
        if let range = responseText.lowercased().range(of: functionCallMarker) {
            let functionCall = String(responseText[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            responseText = String(responseText[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse the function call and extract variables
            if functionCall.lowercased().contains("addevent") {
                let parametersString = functionCall.replacingOccurrences(of: "addEvent(", with: "", options: .caseInsensitive).replacingOccurrences(of: ")", with: "", options: .caseInsensitive)
                let parameters = parametersString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                // print("Parsed parameters: \(parameters)") // Debugging line
                
                if parameters.count == 9 {
                    let title = parameters[0].replacingOccurrences(of: "\"", with: "")
                    if let startYear = Int(parameters[1]),
                       let startMonth = Int(parameters[2]),
                       let startDay = Int(parameters[3]),
                       let startHour = Int(parameters[4]),
                       let endYear = Int(parameters[5]),
                       let endMonth = Int(parameters[6]),
                       let endDay = Int(parameters[7]),
                       let endHour = Int(parameters[8]) {
                        addEvent(title: title, startYear: startYear, startMonth: startMonth, startDay: startDay, startHour: startHour, endYear: endYear, endMonth: endMonth, endDay: endDay, endHour: endHour)
                        print("ADDED EVENT") // Confirmation line
                        
                        // Clear conversation history after adding the event
                        conversationHistory.removeAll()
                        print("\n\nMemory Wiped\n\n") // Confirmation line
                        saveConversationHistory()
                    } else {
                        print("Failed to parse parameters as integers.") // Debugging line
                    }
                } else {
                    print("Incorrect number of parameters.") // Debugging line
                }
            } else {
                print("No addEvent function call found.") // Debugging line
            }
        }
    }
    
    func addEvent(title: String, startYear: Int, startMonth: Int, startDay: Int, startHour: Int, endYear: Int, endMonth: Int, endDay: Int, endHour: Int) {
            
        let startDate = Calendar.current.date(from: DateComponents(year: startYear, month: startMonth, day: startDay, hour: startHour))!
        let endDate = Calendar.current.date(from: DateComponents(year: endYear, month: endMonth, day: endDay, hour: endHour))!
        
        calendarManager.addEventWithPermission(title: title, startDate: startDate, endDate: endDate)
    }
}
