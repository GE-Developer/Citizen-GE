//
//  Color + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Color {
    static let citizen = CitizenColor()
}

struct CitizenColor {
    @MainActor
    var accent: Color {
        AccentColorManager.shared.currentColor.color
    }
    
    let background = Color("Background")
    let blackAndWhite = Color("Black And White")
    let whiteAndBlack = Color("White And Black")
    let white = Color.white
    let black = Color.black
    let groupBackground = Color("Group Background")
    let darkGroupBackground = Color("Dark Group Background")
    let secondaryGroupBackground = Color(.secondarySystemGroupedBackground)
    let secondaryText = Color("Secondary Text")
    let goldLight = Color("Gold Light")
    let goldDark = Color("Gold Dark")
    let grayLight = Color("Gray Light")
    let grayDark = Color("Gray Dark")
    let navBarShadow = Color("NavBar Shadow")
    let viewShadow = Color("View Shadow")
    let textFieldBackground = Color("Text Field Background")
    let mainText = Color("Main Text")
    let greenDark = Color("Green Dark")
    let greenLight = Color("Green Light")
    let yellowLight = Color("Yellow Light")
    let yellowDark = Color("Yellow Dark")
    let redLight = Color("Red Light")
    let redDark = Color("Red Dark")
}
