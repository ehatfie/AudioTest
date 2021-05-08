//
//  ContentView.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let manager = AudioManager()
    @State var isRecording = false
    
    var body: some View {
        VStack {
            Button(action: recordingButtonOnPress, label: {
                let labelText = isRecording ? "Stop" : "Start"
                Text(labelText + " recording")
            })
            .padding()
            .border(Color.black, width: 1)
            Button(action: playbackButtonOnPress, label: {
                Text("play recording")
            })
            .padding()
            .border(Color.black, width: 1)
            HStack {
                Button(action: playAudioButtonOnPress, label: {
                    Text("Play Player")
                })
                .padding()
                .border(Color.black, width: 1)
                Button(action: playAudioButtonOnPress, label: {
                    Text("Play Buffer")
                })
                .padding()
                .border(Color.black, width: 1)
            }.padding()
            
        }
    }
    
    func recordingButtonOnPress() {
        if isRecording {
            manager.stopRecording()
            isRecording = false
        } else {
            manager.startRecording { status in
                isRecording = status
            }
        }
    }
    
    func playbackButtonOnPress() {
        manager.startPlayback()
    }
    
    func playAudioButtonOnPress() {
        print("playt audio on press")
        manager.playAudio()
    }
    
    func playAudioBufferOnPress() {
        manager.playBuffer()
    }
    
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
