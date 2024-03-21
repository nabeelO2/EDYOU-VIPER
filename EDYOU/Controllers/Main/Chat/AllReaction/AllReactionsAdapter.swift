//
//  AllChatReactionsAdapter.swift
//  EDYOU
//
//  Created by Ali Pasha on 11/08/2022.
//

import Foundation
import UIKit

protocol EmojiModelProtocol {
    var emoji: String { get }
    var userName: String { get }
    var userPicture: String { get }
    var userUniversity: String { get }
}


class AllReactionsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    weak var collectionView: UICollectionView!
    
    var parent: AllReactionViewController? {
        return tableView.viewContainingController() as? AllReactionViewController
    }
    
    var emojis: [EmojiModelProtocol]?
    var selectedEmoji : [EmojiModelProtocol]?
    var selected : String?
    var distinguiedEmojis : [String]? = []
    var allEmojis : [String]? = []
    
    // MARK: - Initializers
    init(tableView: UITableView, collectionView: UICollectionView, emojis: [EmojiModelProtocol]) {
        super.init()
        self.emojis = emojis //message.emojis.toArray(type: EmojiModel.self)
        self.tableView = tableView
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        
        for emoji in emojis!
        {
            if !(distinguiedEmojis?.contains(where: { $0 == emoji.emoji }) ?? false) {
                distinguiedEmojis?.append(emoji.emoji)
            }
            allEmojis?.append(emoji.emoji)
        }
        
        self.selected = (distinguiedEmojis?.object(at: 0)) ?? ""
        self.selectedEmoji = self.emojis?.filter { $0.emoji == selected }
        
        tableView.register(ChatReactionUserCell.nib, forCellReuseIdentifier: ChatReactionUserCell.identifier)
        collectionView.register(ChatReactionEmojiCell.nib, forCellWithReuseIdentifier: ChatReactionEmojiCell.identifier)
      
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
}

extension AllReactionsAdapter: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedEmoji?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatReactionUserCell.identifier, for: indexPath) as! ChatReactionUserCell
        
        cell.setupUI(emoji: (selectedEmoji?.object(at: indexPath.row))!)
        return cell
    }
    
    
}
extension AllReactionsAdapter: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return distinguiedEmojis?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: 39, height: 40 )
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatReactionEmojiCell.identifier, for: indexPath) as! ChatReactionEmojiCell
        let currentEmojis = allEmojis?.filter { $0 == (distinguiedEmojis?.object(at: indexPath.row))!}
        if  self.selected == (distinguiedEmojis?.object(at: indexPath.row))!
        {
            cell.setupUI(emoji: (distinguiedEmojis?.object(at: indexPath.row))!, totalCount: currentEmojis?.count, isSelected: true)
        }
        else
        {
            cell.setupUI(emoji: (distinguiedEmojis?.object(at: indexPath.row))!, totalCount: currentEmojis?.count, isSelected: false)
        }
       
            //cell.lblEmoji.text = emojis[indexPath.row].value
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        selected = (distinguiedEmojis?.object(at: indexPath.row))!
        self.selectedEmoji = self.emojis?.filter { $0.emoji == selected }
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}
