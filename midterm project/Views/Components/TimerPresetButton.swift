//
//  TimerPresetButton.swift
//  midterm project
//
//  Created by Christian Louis on 11/16/26.
//

import SwiftUI

struct TimerPresetButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.ulamOrange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.ulamLightOrange)
                .cornerRadius(8)
        }
    }
}
