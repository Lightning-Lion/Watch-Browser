//
//  ContentView.swift
//  browser Watch App
//
//  Created by 凌嘉徽 on 2024/3/9.
//

import SwiftUI
import AuthenticationServices
import Combine

let openLink = PassthroughSubject<String,Never>()

struct ContentView: View {
    @State
    var mod = ViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 6, content: {
                    VStack {
                        if !mod.errorText.isEmpty {
                            Text(mod.errorText)
                        }
                        WebLink(title: "Bing", sfsymbol: "magnifyingglass", url: "https://www.bing.com/", color: Color.yellow)
                        WebLink(title: "Apple", sfsymbol: "apple.logo", url: "https://www.apple.com/", color: Color.blue)
                    }
                })
            }
        }
        .blur(radius: mod.loading ? 13 : 0)
        .overlay(content:loadingView)
        .animation(.smooth, value: mod.errorText)
        .animation(.smooth, value: mod.loading)
        .onReceive(openLink, perform: { url in
            mod.openWebPage(url:url)
        })
    }
    @ViewBuilder
    func loadingView() -> some View {
        if mod.loading {
            ProgressView()
        }
    }
    
}

@Observable
class ViewModel {
    var errorText = ""
    var loading = false
    func cleanError() {
        errorText = ""
    }
    func riseNewError(_ content:String) {
        if errorText.isEmpty {
            errorText = content
        } else {
            errorText += content
        }
    }
    func openWebPage(url:String) {
        cleanError()
        loading = true
        guard url.hasPrefix("http://") || url.hasPrefix("https://") else {
            riseNewError("Please enter a URL start with https://")
            loading = false
            return
        }
        guard let url = URL(string: url) else {
            riseNewError("Please enter the correct URL.")
            loading = false
            return
        }
        // Source: https://www.reddit.com/r/apple/comments/rcn2h7/comment/hnwr8do/
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: nil) { [self] lastURL, error in
                loading = false
            }
        
        // Makes the "Watch App Wants To Use example.com to Sign In" popup not show up
        session.prefersEphemeralWebBrowserSession = true
        
        //slight delay to avoid Application Not Responding
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            session.start()
        }
        //give webpage 0.5s to loading, then dismiss the progressView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            loading = false
        }
    }
}

struct WebLink: View {
    var title:String
    var sfsymbol:String
    var url:String
    var color:Color
    var body: some View {
        Button(action: {
            openLink.send(url)
        }, label: {
            Label(title, systemImage: sfsymbol)
        })
        .buttonStyle(.borderedProminent)
        .tint(color)
    }
}


#Preview {
    ContentView()
}
