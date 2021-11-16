//
//  Fb2_Parser_and_ReaderApp.swift
//  Fb2 Parser and Reader
//
//  Created by Dmitriy Putin on 16.11.2021.
//

import SwiftUI


let preferens = getPlist(withName: "Preferences")
let defaults = UserDefaults.standard


@main
struct Fb2_Parser_and_ReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
