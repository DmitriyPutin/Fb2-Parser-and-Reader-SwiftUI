//
//  ViewModel.swift
//  SferaInfo
//
//  Created by Dmitriy Putin on 04.11.2021.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    var isLoaderVisible = PassthroughSubject<Bool, Never>()
    var webViewNavigationPublisher = PassthroughSubject<ViewNavigationAction, Never>()
}
