//
//  LoaderView.swift
//  SferaInfo
//
//  Created by Dmitriy Putin on 04.11.2021.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        ZStack {
                BlurView()
            VStack {
                Indicatior()
                //Text("Подождите...").foregroundColor(.white).padding(.top, 8)
            }
        }.frame(width: 80, height: 80)
        .cornerRadius(8)
    }
}

struct BlurView: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIVisualEffectView {
        
        let effect = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<BlurView>) { }
}

struct Indicatior : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicatior>) -> UIActivityIndicatorView {

        let indi =  UIActivityIndicatorView(style: .large)
        indi.color = UIColor.white
        indi.startAnimating()
        return indi
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicatior>) { }
}
