//  TextBookContent.swift
//  SferaInfo
//  Просмотр книги (читалка)
//  Created by Dmitriy Putin on 21.10.2021.

import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit
import SQLite3

struct ContentView: View {
    
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var contentsItem = TableOfContents.init(nameContent: "Start", parentContent: nil, keyUid: nil
                                                , lineNumberStart: 1, lineNumberEnd: 1)
    @ObservedObject var viewModel = ViewModel()
    @StateObject var showAlert = ShowAlerts()
    @StateObject var chapterUid = Chapter()
 
    @EnvironmentObject var structurItemsBook: ArrayOffLibrary
  
    @State   private var packetContent: (txtContent: String, contents: [TableOfContents], notes: [TableOfContents] , imageTitleContent: String, mainParser: String, nameContent: String ) = ("", [TableOfContents](), [TableOfContents](),"","","")
    
    @State   var isLoaderVisible = false             ///Индикатор Loader
    @State   var isExit = false                      ///Индикатор alert при выходе из книги
    
    
    var body: some View {
        ZStack {
        NavigationView {
            VStack {
                     WebView(viewModel: viewModel, contensItem: contentsItem
                             , textHtml: $packetContent.txtContent, nameContent: $packetContent.nameContent , showAlert: showAlert, chapterUid: chapterUid )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .gesture(
                              DragGesture(minimumDistance: 20, coordinateSpace: .local)
                             .onEnded({ (value) in
                                 if value.translation.width > 0 {
                                    viewModel.webViewNavigationPublisher.send(.backward)
                                 } else {
                                     viewModel.webViewNavigationPublisher.send(.forward)
                                 }
                             })
                    )
                     /// Alert для чтения примечания
                    .alert("" ,isPresented: $showAlert.showAlert, actions: { }, message: {
                        Text(packetContent.notes.first {$0.KeyUid == showAlert.keyNote}?.NameContent ?? "")
                    })
                    /// Alert для  выхода и сохранения книги во внутренней базе
                    .alert("", isPresented: $isExit, actions: {
                        Button(preferens?.buttonSaveLable ?? "", role:  .cancel, action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    }, message: {
                        Text(packetContent.nameContent)
                    })
                    /// Содержание
                    .sheet(isPresented: $chapterUid.showChapter, content: {
                        
                        TableOfContensView(viewModel: viewModel, contensItem: contentsItem
                                            , contensItems: packetContent.contents,chapterUid: chapterUid)
                                .animation(.default,value: 5)
                    })
                    .navigationBarTitle(Text(packetContent.nameContent)
                                        , displayMode: .inline).font(.system(size: 10, weight: .regular))
                    .navigationBarItems(
                        trailing:
                             HStack {
                                 Button(action: {
                                     viewModel.webViewNavigationPublisher.send(.backward)
                                 }, label: {
                                     Image(systemName: "chevron.left")
                                         .font(.system(size: 15, weight: .regular))
                                         .imageScale(.medium)
                                 })
                                 
                                 Button(action: {
                                     viewModel.webViewNavigationPublisher.send(.forward)
                                 }, label: {
                                     Image(systemName: "chevron.right")
                                         .font(.system(size: 15, weight: .regular))
                                         .imageScale(.medium)
                                 })
                                 
                                 Button(action: {
                                     viewModel.webViewNavigationPublisher.send(.getchapter)
                                 }, label: {
                                     Image(systemName: "list.bullet")
                                         .font(.system(size: 15, weight: .regular))
                                         .imageScale(.medium)
                                 })
                                 
                                 Button(action: {
                                     viewModel.webViewNavigationPublisher.send(.exit)
                                     isExit.toggle()
                                     
                                 }, label: {
                                     Image(systemName: "square.and.arrow.up")
                                         .font(.system(size: 15, weight: .regular))
                                         .imageScale(.medium)
                                 })
                         }
                    )

               }.onReceive(self.viewModel.isLoaderVisible.receive(on: RunLoop.main)) { value in
                           self.isLoaderVisible = value }
         }.onAppear() {
            /// Сохранение в переменной приложения названия последней открытой книги
                 defaults.set(packetContent.nameContent, forKey: "lastBook")
                 defaults.set("", forKey: "chapter")
                 
                 self.isLoaderVisible.toggle()
                         OpenContent().getUnContent() { (packetContent)
                             in self.packetContent = packetContent
                 }
            }
         .blur(radius: self.isLoaderVisible ? 15 : 0)
         .font(.subheadline)
         .preferredColorScheme(.dark)
          
          if isLoaderVisible {
              LoaderView()
          }
      }
   }
}


