//  LabClass.swift
//  SferaInfo
//  Библиотека классов
//  Created by Dmitriy Putin on 15.10.2021.

import SwiftUI
import Foundation
import SQLite
import SwiftyXMLParser

/// Получение TreeView контента

class OpenContent {
    
    func getUnContent(completion: @escaping ((txtContent: String, contents: [TableOfContents], notes: [TableOfContents], imageTitleContent: String , mainParser: String
      , nameContent: String)) -> ()) {
        
        let nameContent = "126915"
        
        let path = Bundle.main.path(forResource: "126915", ofType: "fb2") ?? "126915.fb2"
        let content = try! String(contentsOfFile: path)
        let dataString = content.replacingOccurrences(of: "windows-1251", with: "UTF-8")
        let scrollBook    = defaults.float(forKey: nameContent)
        
        /// Черный "#000000"; Белый "#FFFFFF"
        let packetContent = StartParser.init(sizeFont: 2, fontName: "Verdana", colorFont:     "#000000", colorBackgroud: "#FFFFFF")
             .mainParserFb2(mainParser: dataString, fileName: nameContent, scroll: scrollBook)
        
        completion(packetContent)
    }
}


/// Чтение файла Preferenc.plist
func getPlist(withName name: String) -> Preferences?
{
    if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path),
        let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
    {
        return preferences
    }

    return nil
}

/// Класс для создания содержание книги
class TableOfContents: ObservableObject, Identifiable {
    
    init(nameContent: String,parentContent: String?, keyUid: String?, lineNumberStart: Int, lineNumberEnd: Int ) {
        self.NameContent = nameContent
        self.ParentUID = parentContent
        self.KeyUid = keyUid
        self.lineNumberStart = lineNumberStart
        self.lineNumberEnd = lineNumberEnd
    }
    
    @Published var UID = UUID()
    @Published var NameContent: String = "" 
    @Published var ParentUID: String?
    @Published var KeyUid: String?
    @Published var lineNumberStart: Int
    @Published var lineNumberEnd: Int
}


/// Книга
class JasonRead: Codable {
    var success: Int
    var book: [Book]
}

class Book: Codable {
    var BookName: String
    var DateUpdate: String
    var Content: String
    var TypeId: String
    var ID: String
    var NameType: String
    var Chapter: String
    var NowText: String
}

struct Preferences: Codable {
    var buttonSaveLable:    String
    var buttonExitLable:    String
    var buttonDismissLable: String
}

/// Класс для alert примечания
class ShowAlerts: ObservableObject {
    
    @Published var showAlert:Bool = false
    @Published var keyNote: String = ""
    
    func displayAlert(keyNote: String) {
        self.showAlert.toggle()
        self.keyNote = keyNote
    }
}


class Chapter: ObservableObject {

    @Published var showChapter:Bool = false
    @Published var chapterUid: String = ""
    @Published var scrollchapter: Float = 0
    @Published var scroll: Float = 0
    @Published var count: Float = 0
    @Published var itemId: Float = 0
    
    func getCapter (scrollchapter: Float, scroll: Float, chapterUid: String, count: Float, itemId: Float) {
        self.showChapter.toggle()
        self.chapterUid = chapterUid
        self.scroll = scroll
        self.scrollchapter = scrollchapter
        self.count  = count
        self.itemId = itemId
    }
}

class ArrayOffLibrary: ObservableObject {
 
    @Published var books = [SructuraItemsBook]()
    
    init() { }
    
    func update(books: [SructuraItemsBook]) {
        self.books = books
    }
}

/// Структура для создания списка книг сохраненных на смартфоне
class SructuraItemsBook: ObservableObject, /*Codable,*/ Identifiable, Equatable {
 
    static func == (lhs: SructuraItemsBook, rhs: SructuraItemsBook) -> Bool {
            return lhs.bookId == rhs.bookId
    }
    
    init(bookId: Int64, nameContent: String, imageTitleContent: String, bookContent: String, dateUpdate: Date ) {
        self.bookId      = bookId
        self.nameContent = nameContent
        self.imageTitleContent = imageTitleContent
        self.bookContent = bookContent
        self.dateUpdate  = dateUpdate
    }
    
    @Published var uuid = UUID()
    @Published var bookId: Int64
    @Published var nameContent: String
    @Published var imageTitleContent: String
    @Published var bookContent: String
    @Published var dateUpdate: Date
}



func decodeImage(strBase64: String) -> UIImage {
    let dataDecoded = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
    let decodedImage = UIImage(data: dataDecoded)
    return decodedImage!
}
