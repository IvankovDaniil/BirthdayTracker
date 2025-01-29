//
//  MainFlow.swift
//  BirthdayTracker
//
//  Created by Даниил Иваньков on 19.12.2024.
//

import SwiftUI

struct MainFlow: View {
    @State var isAddBirthdayView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                BirthdaysView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddBirthdayView = true
                    } label: {
                        Text("+")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .sheet(isPresented: $isAddBirthdayView) {
                        AddBirthdayScreen {
                            isAddBirthdayView = false
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    MainFlow()
}
