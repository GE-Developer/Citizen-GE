//
//  Image + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Image {
    static let system = SystemImage()
    static let other = OtherImage()
    
    static func avatar(_ image: CGImage) -> Image {
        Image(decorative: image, scale: 1)
    }
}

struct SystemImage {
    let back = Image(systemName: "chevron.left")
    let chevron = Image(systemName: "chevron.right")
    let lock = Image(systemName: "lock.fill")
    let timer = Image(systemName: "timer")
    let send = Image(systemName: "arrow.up")
    let xmark = Image(systemName: "xmark")
    let checkmark = Image(systemName: "checkmark")
    let number = Image(systemName: "number")
    let magnifyingglass = Image(systemName: "magnifyingglass")
    let darkMode = Image(systemName: "moon.fill")
    let language = Image(systemName: "globe")
    let vibration = Image(systemName: "iphone.radiowaves.left.and.right")
    let sound = Image(systemName: "speaker.wave.2.fill")
    let voiceActing = Image(systemName: "waveform")
    let voiceUnavailable = Image(systemName: "speaker.slash.fill")
    let shuffle = Image(systemName: "shuffle")
    let dice = Image(systemName: "die.face.5")
    let play = Image(systemName: "play.fill")
    let transcription = Image(systemName: "textformat")
    let subscription = Image(systemName: "star")
    let star = Image(systemName: "star.fill")
    let restorePurchases = Image(systemName: "arrow.clockwise")
    let reviewLike = Image(systemName: "hand.thumbsup.fill")
    let termsOfUse = Image(systemName: "doc.plaintext")
    let privacyPolicy = Image(systemName: "lock.doc.fill")
    let developerTool = Image(systemName: "hammer.fill")
    let gear = Image(systemName: "gear")
    let warning = Image(systemName: "exclamationmark.triangle")
    let repeatArrow = Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
    let bookmark = Image(systemName: "bookmark.fill")
    let bookmarkOutline = Image(systemName: "bookmark")
    let folder = Image(systemName: "folder")
    let practice = Image(systemName: "checklist")
    let hint = Image(systemName: "lightbulb")
    let books = Image(systemName: "books.vertical.fill")
    let dictionary = Image(systemName: "character.book.closed.fill")
    let dictionaryOutline = Image(systemName: "character.book.closed")
    let leaderboard = Image(systemName: "chart.bar.fill")
    let contacts = Image(systemName: "person.2.fill")
    let company = Image(systemName: "building.2.fill")
    let verified = Image(systemName: "checkmark.seal.fill")
    let phone = Image(systemName: "phone.fill")
    let website = Image(systemName: "safari")
    let telegram = Image(systemName: "paperplane.fill")
    let whatsapp = Image(systemName: "message.fill")
    let mapPin = Image(systemName: "mappin.and.ellipse")
    let contactInfo = Image(systemName: "person.text.rectangle")
    let addToContacts = Image(systemName: "person.crop.circle.badge.plus")
    let plus = Image(systemName: "plus")
    let paintpalette = Image(systemName: "paintpalette.fill")
    let code = Image(systemName: "chevron.left.slash.chevron.right")
    let appIcon = Image(systemName: "app.fill")
    let envelope = Image(systemName: "envelope")
    let apple = Image(systemName: "apple.logo")
    let person = Image(systemName: "person")
    let signOut = Image(systemName: "rectangle.portrait.and.arrow.right")
    let trash = Image(systemName: "trash")
    let photo = Image(systemName: "photo")
    let camera = Image(systemName: "camera.fill")
    let sync = Image(systemName: "arrow.triangle.2.circlepath")
    let copy = Image(systemName: "doc.on.doc")
    let eraser = Image(systemName: "eraser")
    let deleteData = Image(systemName: "externaldrive.badge.xmark")
    let bolt = Image(systemName: "bolt.fill")
    func key(_ isFilled: Bool = false) -> Image {
        Image(systemName: isFilled ? "key.fill" : "key")
    }
    
    func lock(_ isOpen: Bool) -> Image {
        isOpen ? Image(systemName: "lock.open.fill") : lock
    }
    
    func checkmarkInCircle(_ isFilled: Bool = true) -> Image {
        Image(systemName: isFilled ? "checkmark.circle.fill" : "circle")
    }
    
    func checkmarkAndXmark(_ isCorrect: Bool) -> Image {
        isCorrect ? Image(systemName: "checkmark") : xmark
    }
    
    func eye(_ isRevealed: Bool) -> Image {
        Image(systemName: isRevealed ? "eye.slash" : "eye")
    }
}

struct OtherImage {
    let checkmark = Image("Logo Checkmark")
    let instagram = Image("instagram")
    let iosDeveloperMichael = Image("iOS Developer")
    let svgLogo = Image("SVG Logo")
}
