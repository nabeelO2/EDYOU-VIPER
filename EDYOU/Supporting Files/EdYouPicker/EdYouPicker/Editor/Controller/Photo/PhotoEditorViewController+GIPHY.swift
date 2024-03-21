//
//  PhotoEditorViewController+GIPHY.swift
//  ustories
//
//  Created by imac3 on 10/07/2023.
//

import Foundation
#if canImport(GiphyUISDK)
import GiphyUISDK


extension PhotoEditorViewController {
    
    func showGiphy(){
        Giphy.configure(apiKey: EDYouPicker.shared.giphyAPIKey)
        let mediaTypeConfig: [GPHContentType] = [.recents,.emoji,.gifs,.stickers,.text]
        let theme: GPHThemeType = GPHThemeType.automatic
        let giphy = GiphyViewController()
        giphy.theme = GPHTheme(type: theme)
        giphy.mediaTypeConfig = mediaTypeConfig
        GiphyViewController.trayHeightMultiplier = 0.7
        giphy.showConfirmationScreen = false
        giphy.shouldLocalizeSearch = true
        giphy.delegate = self
        giphy.dimBackground = true
        giphy.enableDynamicText = true
         
        giphy.modalPresentationStyle = .overCurrentContext
        
        if let contentType = self.selectedContentType {
            giphy.selectedContentType = contentType
        }
        if let user = self.showMoreByUser {
            giphy.showMoreByUser = user
            self.showMoreByUser = nil
        }
        
        present(giphy, animated: true, completion: nil)
    }
    
    func hideGiphy(){
        print("hide giphy")
        
    }
    
    
}



extension PhotoEditorViewController: GiphyDelegate {
    
    public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia, contentType: GPHContentType) {
        print(contentType.rawValue)
    }
    
    public func didSearch(for term: String) {
        print("your user made a search! ", term)
    }
    
    public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
     //   showMoreByUser = nil
        self.selectedContentType = giphyViewController.selectedContentType
        giphyViewController.dismiss(animated: true, completion: { [weak self] in
            print(media)
            
            guard let url = media.url(rendition: .fixedWidth, fileType: .gif) else { return }
            GPHCache.shared.downloadAssetData(url) { (data, error) in
                if let data = data{
                    let image = UIImage(data: data)
                    print(image)
                    
                    let item = EditorStickerItem(
                        image: image!,
                        imageData: data,
                        text: nil
                    )
                    self?.imageView()?.addSticker(
                        item: item,
                        isSelected: false
                    )
                }
                
                
                print("data")
                
            }
            
            
            self?.singleTap()
            
          //  self?.addMessageToConversation(text: nil, media: media)
//            guard self?.conversation.count ?? 0 > 7 else { return }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
//                guard let self = self else { return }
//                let response = self.conversationResponses[self.currentConversationResponse % self.conversationResponses.count]
//                self.currentConversationResponse += 1
//                self.addMessageToConversation(text: response, user: .abraHam)
//            }
        })
        GPHCache.shared.clear()
    }
    
    public func didDismiss(controller: GiphyViewController?) {
        GPHCache.shared.clear()
    }
    
}


#endif
