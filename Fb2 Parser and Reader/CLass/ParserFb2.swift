//  ParserFb2.swift
//  SferaInfo
//  Собрать HTML для отображения в WKWebView
//  Created by Dmitriy Putin on 25.10.2021.

import Foundation
import SwiftyXMLParser
import SwiftUI
import SQLite
import Combine

class StartParser {
    

    @Published var sizeFont:  Float
    @Published var fontName:  String
    @Published var colorFont: String
    @Published var colorBackgroud: String
    
    var xmlArray  = [XML.Element]()
    var textHtml  = [String]()
    var textBody  = [String]()

    var colorFoneKey = "transparent"
    var imageTitleContent = ""
    var tableOfContents = [TableOfContents]()
    var tableOfNotes    = [TableOfContents]()
    
    init(sizeFont: Float, fontName: String, colorFont: String, colorBackgroud: String ) {
        self.sizeFont = sizeFont
        self.fontName = fontName
        self.colorFont = colorFont
        self.colorBackgroud = colorBackgroud
    }
    
    /// Функция запуска парсинга
    func mainParserFb2(mainParser: String, fileName: String, scroll: Float ) ->
    (txtContent: String, contents: [TableOfContents], notes: [TableOfContents], imageTitleContent: String, mainParser: String, nameContent: String) {
        
        var script = "<script type=\"text/javascript\">"
        
        for scriptItem in ScriptArray {
            script = script + scriptItem.value
        }
        script = script + "</script>"
        
        let bodyStart = "<body onload=\"getLoad('\(fileName)',\(scroll))\">"
             
        let style = """
               body { background-color: \(colorBackgroud);}
               img {display: inline-block;  max-width: 500px; }
               div { text-align: justify; line-height: \(sizeFont * 1.2)em; }
               h2  { line-height: 1.5; }
               p { display: block; margin-top: 1em; margin-bottom: 0.2em; margin-left: 0.2em; margin-right: 0.2em; font-size: \(sizeFont)em;
               font-family: \(fontName); color: \(colorFont); text-indent:  0.2em;}
        """
        
        //let meta = "<meta charset=\"utf-8\">"
        
        let startHtml = """
            <!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><style type=\"text/css\">\(style)</style></head>\(bodyStart)
            <center><h2><font color \"#008000\"></font></h2></center><div class=\"blocktext\" id=\"tbl\">
        """
        
        let endHtml = "<a style=\"color:\(colorFoneKey);\"><font size=\(sizeFont * 0.05)em>endItemContext</font></a></div></body>\(script)</html>";
        
        textHtml.append(startHtml)
        
        /// Парсинг xml в массив элементов
        xmlArray = try! XML.parse(mainParser).element!.childElements[0].childElements
        
        parcerFb2ElementParent(xml: xmlArray, parentName: nil)
        
        textHtml.append(contentsOf: textBody)
        textHtml.append(endHtml)
        
        var txtAll = ""
        
        for item in self.textHtml {
            txtAll = txtAll + item + "\n"
        }
        
        return (txtAll, tableOfContents, tableOfNotes, imageTitleContent, mainParser,fileName)
    }
    
    
    /// Парсинг в HTML объекта полученного после парсинга XML-файла
    func parcerFb2ElementParent(xml: [XML.Element], parentName: String?) {
        
        for item in xml {
            if item.childElements.count > 0 {
                
                switch (item.name) {
                    case "p":
                        addString(element: item)
                        break
                    case "section", "body":
                         ///    Добавить массив справочник Content и Примечания
                         if (item.attributes.count == 0 || (item.attributes.first(where:
                            { (key: String, value: String) in return value == "notes" }) != nil)) {
                             
                             guard let dataContent = (item.childElements.first {$0.name == "title"}) else { break }
                             insertDataContents(element: dataContent)

                         } else {
                             if item.name == "section" {
                                 guard let dataContent = (item.childElements.first {$0.name == "p"}) else { break }
                                 insertDataContents(element: dataContent)
                             }
                         }
                       break
                    default:
                        break
                }
                parcerFb2ElementParent(xml: item.childElements, parentName: item.name)
                
            } else {
                addString(element: item)
            }
        }
    }
    
    /// Разбор  элементов
    func addString(element: XML.Element) {
        
        switch (element.name) {
        case "book-title":
            booktitle(element: element)
            break
        case "image":
            image(element: element)
            break
        case "p", "custom-info", "strong":
            p(element: element)
            break
        case "empty-line":
            textBody.append("\n")
        case "a":
            lincContent(element: element)
            break
        case "emphasis":
            emphasis(element: element)
            break
        default:
            break
        }
    }
    
    ///   Картинки в книге
    func image(element: XML.Element) {
        
        var filterBinaryMain = xmlArray.filter {$0.name == "binary"}
        filterBinaryMain.append(contentsOf: element.childElements.filter {$0.name == "binary"})
        
        if filterBinaryMain.count > 0 {
            
            guard var keyImage = element.attributes.first?.value  else {return}
            
            keyImage = keyImage.replacingOccurrences(of: "#", with: "", options: .regularExpression, range: nil)
            
            for item in filterBinaryMain {
                
                let attribute = item.attributes.first(where: { (key: String, value: String) in return value == keyImage })
                
                if attribute != nil {
                    
                    let attributeImage = item.attributes.first(where: { (key: String, value: String) in return key == "content-type" })
                    
                    if imageTitleContent == "" {
                        imageTitleContent.append(item.text ?? "")
                    }
                    
                    if attributeImage != nil {
                        textBody.append("<center><img src=\"data:\(attributeImage?.value ?? "image/png") ;base64,\(item.text ?? "")\"></center>")
                    } else {
                        textBody.append("<center><img src=\"data:image/png;base64,\(item.text ?? "")\"></center>")
                    }
                }
            }
        }
    }
    
    ///     Добавить в таблицу  Content
    func insertDataContents(element: XML.Element) {
     
        if element.name == "title" {
            var nameContent = ""
        
            for item in element.childElements {
                if item.childElements.count > 0 {
                    for itemChild in item.childElements {
                        nameContent.append(itemChild.text ?? "")
                    }
                } else {
                    nameContent.append(item.text ?? "")
                }

            }
            
            tableOfContents.append(TableOfContents.init(nameContent: nameContent, parentContent: nil, keyUid: nil
                      , lineNumberStart: element.lineNumberStart, lineNumberEnd: element.lineNumberEnd))
            textBody.append("<a class=\"chapter\" id=\"\(String(describing: tableOfContents.last?.UID ?? UUID()))\" style=\"color:\(colorFoneKey);\"><font size=\"\( sizeFont * 0.05)em\"></font></a>");
        
        } else {
     
            let keyUid = "#".appending(element.parentElement?.attributes.first?.value ?? "")
            tableOfNotes.append(TableOfContents.init(nameContent: element.text ?? "", parentContent: nil, keyUid: keyUid
                      , lineNumberStart: element.lineNumberStart, lineNumberEnd: element.lineNumberEnd))
        
        }
    }
    
    /// Заголовок книги
    func booktitle(element: XML.Element) {
        textBody.append("<center><h2><p><b>\(String(describing: element.text ?? ""))</center></h2></b></p>")
    }
    
    ///  Сноска
    func lincContent(element: XML.Element) {
        
        let attribute = element.attributes.first(where: { (key: String, value: String) in return value == "note" })
        
        if attribute != nil {
            
            let keyNote = element.attributes.first(where: { (key: String, value: String) in return key == "l:href" })

            let link = "<a href=\"javascript:setlinkContent('\(keyNote?.value ?? "")')\" style=\"color:blu;\"><font size=\"\( sizeFont * 2.05)em\">"
             + "\(String(describing: element.text ?? ""))</font></a>"
            
            let paragraphLink = (String(describing: textBody.last ?? "<p></p>").replacingOccurrences(of: "</p>", with: "<font size=\"\(sizeFont*0.8)em\">\(link)</font></p>", options: .regularExpression, range: nil))
            
            textBody.removeLast()
            textBody.append(paragraphLink)
        }
 
    }
    
    
    func emphasis(element: XML.Element) {
        
        let paragraphEphasis = (String(describing: textBody.last ?? "<p></p>").replacingOccurrences(of: "</p>", with: "<font size=\"\(sizeFont)em\">\(String(describing: element.text ?? ""))</font></p>", options: .regularExpression, range: nil))
        
        textBody.removeLast()
        textBody.append(paragraphEphasis)
    }
    
    ///  Параграф
    func p(element: XML.Element) {
        switch (element.parentElement?.name) {
        case "title":
            textBody.append("<center><h2><p><b>\(String(describing: element.text ?? ""))</center></h2></b></p>")
            break
        case "section":

            if ((element.parentElement?.attributes.count)! > 0 ) {
                textBody.append("<p><font size=\"\(sizeFont)em\"><i>\(String(describing: element.text ?? ""))</font></i></p>")
            } else {
                textBody.append("<p>&nbsp;&nbsp;\(String(describing: element.text ?? ""))</p>")
            }

        case "epigraph", "text-author":
            textBody.append("<p align=\"right\"><font size=\"\(sizeFont)em\"><i>\(String(describing: element.text ?? ""))</font></i></p>")
            break
        default:
            if element.parentElement?.parentElement?.name == "title" {
                textBody.append("<center><h2><p><b>\(String(describing: element.text ?? ""))</center></h2></b></p>")
            } else {
                textBody.append("<p>&nbsp;&nbsp;\(String(describing: element.text ?? ""))</p>")

            }
            break
        }
    }
}

