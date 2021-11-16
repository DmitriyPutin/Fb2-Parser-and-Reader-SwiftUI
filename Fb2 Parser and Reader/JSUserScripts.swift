//  JavaScript.swift
//  SferaInfo
//
//  Created by Dmitriy Putin on 31.10.2021.

import Foundation

class ScriptItem {
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    var key: String = ""
    var value: String = ""
}

let ScriptArray
                 = [
                    ScriptItem.init(key: "getLoad", value: getLoad),
                    ScriptItem.init(key: "getForward", value: getForward),
                    ScriptItem.init(key: "getSearchItem", value: getSearchItem),
                    ScriptItem.init(key: "getCloseDocument", value: getCloseDocument),
                    ScriptItem.init(key: "setlinkContent", value: setlinkContent),
                    ScriptItem.init(key: "getChapter", value: getChapter)
                  ]

/// При открытыи книги ищет и устанавливает  месть последнего прочтения
let getLoad  = """
function getLoad(nameFile, scroll) { var oRows = document.getElementById("tbl");
   document.documentElement.scrollTop = scroll;
   var hight = parseFloat(oRows.clientHeight);
   window.webkit.messageHandlers.getLoad.postMessage({ nameFile: nameFile,
   hight: hight, windhight: window.outerHeight }); return true;}
"""


/// Листает на 1 страницу назад или вперед
let getForward  = """
function getForward(index) { var scroll = document.documentElement.scrollTop;
   var windHight = window.innerHeight;
   if (index == 1) {
     document.documentElement.scrollTop = scroll + windHight;
   } else {
     if ( scroll > window.outerHeight) { document.documentElement.scrollTop = scroll - windHight; }
     else { document.documentElement.scrollTop = 0;}
   }
   return true;}
"""

/// Поиск главы из содержания
let getSearchItem = """
function getSearchItem(contentUid) {
     document.getElementById(contentUid).scrollIntoView();
     return true;}
"""

/// Сохранения места последнего прочтения при закрытии книги
let getCloseDocument = """
function getCloseDocument(nameContent) {
    window.webkit.messageHandlers.getCloseDocument.postMessage({scroll: document.documentElement.scrollTop, nameContent: nameContent}); return true;}
"""

/// Ссылка на примечание
let setlinkContent = """
function setlinkContent(keyLink)
    { window.webkit.messageHandlers.setlinkContent.postMessage({keyLink: keyLink}); return true;}
"""

/// Поиск главы на которой открыта книга
let getChapter = """
function getChapter() {
      var scroll  = document.documentElement.scrollTop;
      var array   = document.getElementsByClassName("chapter");
      var windHight = window.innerHeight;
      
      var i = 0;
      var count = array.length;
      var item = 0;
      var itemId = 0;
      var chapter = "";
      
      if (count > 0) {
          do {
                 var chapter = array[i].id;
                 var item = parseFloat(document.getElementById(chapter).offsetTop)-windHight;
                 var itemId = i
                 i++;
          } while (item < scroll && i < count );
          
          switch (itemId) {
             case 0:
                var chapter = array[itemId].id;
                break;
             default:
                if (scroll > item) {
                      var chapter = array[itemId].id;
                } else {
                      var chapter = array[itemId-1].id;
                      var itemId = itemId-1;
                }
                break;
          }
          
          var item = parseFloat(document.getElementById(chapter).offsetTop)-windHight;
      }
      
      window.webkit.messageHandlers.getChapter.postMessage(
                     {scrollchapter: item, scroll: scroll, chapter: chapter, count: count, itemId: itemId }); return true;}
"""
