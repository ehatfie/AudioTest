//
//  ButtonState.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/11/21.
//

import Foundation
import SwiftUI

public enum ButtonState {
    case pressed
    case notPressed
}

public struct TouchDownUpEventModifier: ViewModifier {
    
    /// Properties marked with `@GestureState` automatically resets when the gesture ends/is cancelled
    /// for example, once the finger lifts up, this will reset to false
    /// this functionality is handled inside the `.updating` modifier
    @GestureState private var isPressed = false
    
    let changeState: (ButtonState) -> Void
    
    public func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { (value, gestureState, transaction) in
                gestureState = true
            }
        
        return content
            .gesture(drag)
            .onChange(of: isPressed, perform: { (pressed) in
                if pressed {
                    self.changeState(.pressed)
                } else {
                    self.changeState(.notPressed)
                }
            })
    }
    
    public init(changeState: @escaping (ButtonState) -> Void) {
        self.changeState = changeState
    }
}
