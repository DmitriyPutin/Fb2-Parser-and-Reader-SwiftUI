//
//  TableOfContensView.swift
//  SferaInfo
//  Содержание книги
//  Created by Dmitriy Putin on 06.11.2021.
//

import SwiftUI

struct TableOfContensView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var viewModel: ViewModel
    @ObservedObject var contensItem: TableOfContents
    
    @State   var contensItems = [TableOfContents]()
 
    @State   var color: Color    = .blue
    @State   var number: CGFloat = 12
    @State   var chapterUid: Chapter
    
    var body: some View {
        Rectangle()
            .frame(width: 40, height: 5)
            .cornerRadius(3)
            .opacity(0.1)
        NavigationView {
            List(contensItems) {
                item in
                ZStack {
                     HStack {
                            Image(systemName: "book")
                                Button(action: {
                                    self.contensItem.UID = item.UID
                                    self.contensItem.NameContent = item.NameContent
                                    self.contensItem.ParentUID = item.ParentUID
                                    self.contensItem.KeyUid = item.KeyUid
                                    self.contensItem.lineNumberStart = item.lineNumberStart
                                    self.contensItem.lineNumberEnd = item.lineNumberEnd
                                    self.presentationMode.wrappedValue.dismiss()
                                    viewModel.webViewNavigationPublisher.send(.search)
                                 })
                                  {
                                      if "\(item.UID)" != chapterUid.chapterUid  {
                                           Text(item.NameContent).modifier(textItem())
                                                .foregroundColor(color)
                                                .font(.system(size: number, weight: .bold))
                                      } else {
                                          Text(item.NameContent).modifier(textItem())
                                               .foregroundColor(.red)
                                               .font(.system(size: number, weight: .bold))
                                     }
                                }
                          }
                    }
             }
        }
    }
}


/// Форма Item для TreeView
struct textItem: ViewModifier  {
    
    func body(content: Content) -> some View {
        content.font(.system(size: 14, weight: .bold))
    }
}
