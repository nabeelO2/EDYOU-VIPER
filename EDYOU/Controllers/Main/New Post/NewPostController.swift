//
//  NewPostController.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import UIKit
import DPTagTextView
import Photos
import TransitionButton
import PanModal
import MobileCoreServices


protocol NewPostActionsProtocol {
    
}

class NewPostController: BaseController {
    // MARK: - Outlets
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var txtPost: DPTagTextView!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var tagUserTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cstStackViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var stkPlaceholder: UIStackView!
    @IBOutlet weak var cstStkPlaceholderTop: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stkToolbar: UIStackView!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var cstTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewGradient: GradientView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var lblPostSettings: UILabel!
    @IBOutlet weak var lblPostPrivacy: UILabel!
    @IBOutlet weak var btnPost: TransitionButton!
    @IBOutlet weak var viewPostPrivacy: UIView!
    @IBOutlet weak var imgDownArrow: UIImageView!
    @IBOutlet weak var cstImgDownArrowTrailing: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBgColors: UICollectionView!
    @IBOutlet weak var viewCloseBgColors: UIView!
    @IBOutlet weak var constFeelingHeightContraint: NSLayoutConstraint!
    
    var tagEventAdapter: NewPostEventsAdapter!
    var tagGroupAdapter: NewPostGroupsAdapter!
    var tagFilesAdapter: NewPostTagFilesAdapter!
    var tagUserAdapter: NewPostTagUsersAdapter!
    var attachmentsAdapter: NewPostAttachmentsAdapter!
    var locationFeelingAdapter: LocationAndFeelingsAdapter!
    var colorsBgAdapter: ColorsBgAdapter!
    var tagNumber = 0
    var groupId: String?
    var selectedPostSetting: PostSettings = .oneDay
    var selectedPostPrivacy: PostPrivacy = .friends
    var selectedLocation: LocationModel?
    var selectedFriends = [User]()
    var selectedEmoji: PostEmojiCollection? = nil
    var postSelectedAttachmentType: NewPostTagAttachmentType = .none
    var selectedGroup : Group?
    var selectedEvent : Event?
    var isScreenPresentFromGroup = false
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        viewGradient.colors = [.clear, .clear]
        viewGradient.isHidden = true
        viewPostPrivacy.isHidden = groupId != nil
        imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
        self.txtPost.dpTagDelegate = self
        tagUserAdapter = NewPostTagUsersAdapter(tableView: tagUserTableView, didSelectUser: { [weak self] user in
            guard let self = self else { return }
            self.txtPost.text = self.txtPost.text + "\(user.formattedUserName.first)"
            self.txtPost.addTag(tagText: "@\(user.formattedUserName)", id: user.userID!)
            
           // self.tagUserTableView.isHidden = true

            if self.txtPost.text?.hasSuffix("@\(user.formattedUserName)") != true {
                
                self.txtPost.addTag(tagText: "@\(user.formattedUserName)", id: user.userID!)
                self.stkPlaceholder.isHidden = self.txtPost.text.count > 0
                
                
            }
        })
        
        tagEventAdapter = NewPostEventsAdapter(tableView: tableView)
        tagGroupAdapter = NewPostGroupsAdapter(tableView: tableView)
        tagFilesAdapter = NewPostTagFilesAdapter(tableView: tableView)
        attachmentsAdapter = NewPostAttachmentsAdapter(collectionView: collectionView)
        locationFeelingAdapter = LocationAndFeelingsAdapter(collection: tagsCollectionView)
        
        colorsBgAdapter = ColorsBgAdapter(collectionView: collectionViewBgColors, didSelect: { [weak self] bg in
            guard let self = self else { return }
            
            self.setTextViewFont(size: 14, color: .white, placeholderColor: UIColor.white.withAlphaComponent(0.7))
            self.viewGradient.colors = bg.colors
            self.viewGradient.startPoint = bg.startPoint
            self.viewGradient.endPoint = bg.endPoint
            
        })
        if let id = groupId {
            getGroupMembers(id: id)
        } else {
            getFriends()
        }
        
        selectedPostSetting = AppDefaults.shared.postSettings
        lblPostSettings.text = selectedPostSetting.description
        if let group = self.selectedGroup {
            self.groupSelected(group: group)
        }
        self.tableView.backgroundColor = UIColor.clear
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            imgDownArrow.isHidden = false
            cstImgDownArrowTrailing.constant = 20
            let groupHeight = groupId == nil ? 50 : 0
            cstStackViewBottom.constant = (frame.height - Application.shared.safeAreaInsets.bottom - CGFloat(groupHeight)) * -1
        } else {
            cstStackViewBottom.constant = 0
            cstImgDownArrowTrailing.constant = -20
            imgDownArrow.isHidden = true
        }
        view.layoutIfNeeded(true)
    }
}

// MARK: - Actions
extension NewPostController: PostSelectedTagDelegate,TagEventVCDelegate {
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        //goBack()
        resetCreatePostView()
        self.tabBarController?.selectedIndex = 0

        if groupId != nil {
            dismiss(animated: true)
            
        }
    }
    
    @IBAction func didTapAddBackgroundButton(_ sender: UIButton) {
        view.endEditing(true)
        self.attachmentsAdapter.removeAssets()
        self.tagFilesAdapter.fileURLs.removeAll()
        self.tagFilesAdapter.documentsMedia.removeAll()
        self.selectedEvent = nil
        //self.selectedGroup = nil
        //self.tagGroupAdapter.group = []
        self.tagEventAdapter.event = nil
        self.tableView.isHidden = true
        self.locationFeelingAdapter.tags.removeAll()
        self.tagsCollectionView.isHidden = true
        collectionView.isHidden = true
        
        if let bg = colorsBgAdapter.selectedBackground() {
            viewGradient.colors = bg.colors
            viewGradient.startPoint = bg.startPoint
            viewGradient.endPoint = bg.endPoint
            postSelectedAttachmentType = .background
        }

        setTextViewFont(size: 14, color: .white, placeholderColor: UIColor.white.withAlphaComponent(0.7))
        
        viewGradient.isHidden = false
        tagUserAdapter.textColor = .white
        viewCloseBgColors.showView()
        collectionViewBgColors.showView()
    }
    
    @IBAction func didTapPostSettingsButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let controller = PostSettingsDropDownController(selectedSetting: selectedPostSetting) { settings in
            self.selectedPostSetting = settings
            AppDefaults.shared.postSettings = settings
            self.lblPostSettings.text = settings.description
        }
        self.presentPanModal(controller)
    }
    
    @IBAction func didTapPostPrivacyButton(_ sender: UIButton) {
        view.endEditing(true)
        let controller = PostPrivacyDropDownController(selectedPrivacy: selectedPostPrivacy, delegate: self)
        self.presentPanModal(controller)
    }
    
    @IBAction func didTapCloseBackgroundButton(_ sender: UIButton) {
        setTextViewFont(size: 14, color: .black, placeholderColor: R.color.sub_title() ?? .lightGray)
        postSelectedAttachmentType = .none
        viewGradient.isHidden = true
        tagUserAdapter.textColor = .black
        viewCloseBgColors.hideView()
        collectionViewBgColors.hideView()
    }
    
    // INFO: button functionality changed from user tag to open all tag options
    @IBAction func didTapTagButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let allTagOptionsVC = PostAllTagOptions()
        allTagOptionsVC.delegate = self
        self.present(allTagOptionsVC, presentationStyle: .overCurrentContext)
    }
    
    @IBAction func didTapTagSuggestionButton(_ sender: UIButton) {
        txtPost.becomeFirstResponder()
        txtPost.text = txtPost.text + "@"
        textViewDidChange(txtPost)
    }
    
    func openSelectedTag(option: String) {
        view.endEditing(true)
        
        if (option == "photo") {
            self.didTapAttachImageButton(UIButton())
        } else if (option == "video") {
            self.didTapAttachImageButton(UIButton())
        } else if (option == "file") {
            self.didTapAddFileButton(UIButton())
        } else if (option == "feeling") {
            self.didTapAddEmojiButton(UIButton())
        } else if (option == "place") {
            self.didTapAddLocationButton(UIButton())
        } else if (option == "event") {
            let tagEventVC = TagEvent()
            tagEventVC.delegate = self
            self.presentPanModal(tagEventVC)
        }
    }
    
    func updateTaggedEvent(event: Event?) {
        if (event != nil) {
//            self.attachmentsAdapter.medias.removeAll()
            self.selectedGroup = nil
            self.selectedEvent = event!
            self.tagEventAdapter.event = self.selectedEvent!
            self.tagEventAdapter.configure()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.selectedEvent = nil
            self.tableView.isHidden = true
        }
    }
    
    @IBAction func didTapHideKeybaordButton(_ sender: UIButton) {
        view.endEditing(true)
    }
    
    func prepareCollectionViewFor(tags: Bool = false) {
        
        if let selectedGroup = self.selectedGroup {
            self.tagGroupAdapter.group = [selectedGroup]
        } else {
            self.tagGroupAdapter.group = []
        }
        if let selectedEvent = self.selectedEvent {
            self.tagEventAdapter.event = selectedEvent
        } else {
            self.tagEventAdapter.event = nil
        }
        self.tagFilesAdapter.fileURLs.removeAll()
        self.tagFilesAdapter.documentsMedia.removeAll()
        self.selectedEmoji = nil
        self.selectedLocation = nil
        // Attachments
        self.collectionView.isHidden = false
        self.collectionViewHeightConstraint.constant = 88
        self.collectionView.reloadData()
        //Feelings and Locations
        self.tagsCollectionView.isHidden = false
        self.tagsCollectionView.reloadData()
        self.constFeelingHeightContraint.constant = 38
        
    }
    
    private func resetCreatePostView() {
        self.txtPost.text = nil
        viewGradient.colors = [.clear, .clear]
        viewGradient.isHidden = true
        setupUI()
        didTapCloseBackgroundButton(btnPhoto)
        self.selectedEvent = nil
        self.selectedGroup = nil
        self.attachmentsAdapter.removeAssets()
    }
    
    @IBAction func didTapAttachImageButton(_ sender: UIButton) {
        view.endEditing(true)
        
//        showYP()
//        return
        var isVideoType: Bool = true
       // var mediaType = [kUTTypeMovie as String]
        if sender == self.btnPhoto {
            isVideoType = false
        }
        
        var sheetOptions: [String]?
        sheetOptions = ["Camera", "Gallery"]
        showActionSheet(sheetOptions: sheetOptions!, isTypeVideo: isVideoType)

//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//            self.prepareCollectionViewFor()
//            self.postSelectedAttachmentType = .imageOrVideo
//            ImagePicker.shared.openCameraWithType(from: self, mediaType: mediaType, completion: self.handleImageSelection)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
//            self.prepareCollectionViewFor()
//            self.postSelectedAttachmentType = .imageOrVideo
//            ImagePicker.shared.openGalleryWithType(from: self, mediaType: mediaType, completion: self.handleImageSelection)
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showEDPicker(_ isTypeVideo : Bool,_ preSelected : [EDMediaItem] = []){
        var config = EDImagePickerConfiguration()

       

        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = isTypeVideo ? .video : .photo
        config.library.itemOverlayType = .none
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true

       
        /* Enables you to opt out from saving new (or old but filtered) images to the
           user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

       

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
           Default value is `.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        config.screens = [.library]

        /* Can forbid the items with very big height with this property */
        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 500.0

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .rectangle(ratio: (16/9))

        /* Changes the crop mask color */
        // config.colors.cropOverlayColor = .green

       
        config.albumName = "EDYOU"
        
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"

        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        config.library.defaultMultipleSelection = true
        config.library.preSelectItemOnMultipleSelection = false
        
        
        //config.library.options = options

        
        config.library.preselectedItems = preSelected


       
        let picker = EDImagePicker(configuration: config)

        picker.imagePickerDelegate = self

     
        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in

            var assets = [PhoneMediaAssets]()
            
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            items.forEach { obj in
                var asset = PhoneMediaAssets()
                
                switch obj {
                case .photo(let photo):
                    asset.image = photo.image
                    let width = Int(photo.image.size.width)
                    let height = Int(photo.image.size.height)
                  
                    asset.dimenstions = "\(width)x\(height)"
//                    asset.isImage = true
//                    asset.fileName = photo.exifMeta["name"] as? String
//                    asset.imageData = photo.
                case .video(let video):
                    let data = try! Data(contentsOf: video.url)
                
                    asset.videoData = data
                    
//                    asset.isImage = false
                    asset.videoDuration = video.url.getVideoDuration()
                    asset.thumbnailImage = video.thumbnail == nil ? video.url.getThumbnailImage() : video.thumbnail
                    
                }
                assets.append(asset)
            }
            
            self.handleImagesSelection(data: assets)
            picker?.dismiss(animated: true, completion: nil)
            return;
//            self.selectedItems = items
//            if let firstItem = items.first {
//                switch firstItem {
//                case .photo(let photo):
////                    self.selectedImageV.image = photo.image
//
//                    let exif = photo.exifMeta
//                    let width = photo.image.size.width
//                    let height = photo.image.size.height
//                    let ratio = height / width
////                    self.previewImgVH.constant = self.view.frame.width * ratio
////                    self.previewImgVW.constant = self.view.frame.width
////                    self.previewImgV.image = photo.image
//
//                    print(photo)
//                    picker?.dismiss(animated: true, completion: nil)
//                case .video(let video):
////                    self.selectedImageV.image = video.thumbnail
//
////                    let assetURL = video.url
////                    let playerVC = AVPlayerViewController()
////                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
////                    playerVC.player = player
////
////                    picker?.dismiss(animated: true, completion: { [weak self] in
////                        self?.present(playerVC, animated: true, completion: nil)
//                        print("😀 ")
////                    })
//                }
//            }
        }


        present(picker, animated: true, completion: nil)
    }
    
    func showActionSheet( sheetOptions:[String], isTypeVideo: Bool ) {
       
        let mediaType = isTypeVideo ?  (kUTTypeMovie as String)  : (kUTTypeImage as String)
        
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            if selected == "Camera" {
                self.prepareCollectionViewFor()
                self.postSelectedAttachmentType = .imageOrVideo
                ImagePicker.shared.openCameraWithType(from: self, mediaType: [mediaType], completion: { asset in
                    print(asset)
                    if let img = asset.image {//for images
                        
                        let photo = EDMediaPhoto(image: img)
//                        photo.asset = asset.
                        let item = EDMediaItem.photo(p: photo)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                            self.showEDPicker(isTypeVideo, [item])
                        }
                       
                    }
                    else{//for video
                        if let thumbImg = asset.thumbnailImage, let url = asset.videoURL{
                            let video = EDMediaVideo(thumbnail: thumbImg,videoURL: url)
    //                        photo.asset = asset.
                            let item = EDMediaItem.video(v: video)
                            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                                self.showEDPicker(isTypeVideo, [item])
                            }
                        }
                        
                    }
                    
                    
                })
            } else if selected == "Gallery" {
                self.prepareCollectionViewFor()
                self.postSelectedAttachmentType = .imageOrVideo
                self.showEDPicker(isTypeVideo)
//                ImagePicker.shared.openGalleryWithType(from: self, mediaType: mediaType, completion: self.handleImageSelection)
                
//                if isTypeVideo{
//                    ImagePicker.shared.openGalleryWithType(from: self, mediaType: [mediaType], completion: self.handleImageSelection)
//                }
//                else{
//                    ImagePicker.shared.openGalleryWithTypeMultiplePick(from: self, mediaType: mediaType, completion: self.handleImagesSelection(data:))
//                }
                
                
//                ImagePicker.shared.openGalleryUsingHXPHImagePicker(from: self) { mediaFiles in
//                    self.stopLoading()
//                    self.medias = mediaFiles
//                }
            }
           
        })
        
        self.presentPanModal(genericPicker)
    }
    
    private func handleImageSelection(data: PhoneMediaAssets) {
        self.attachmentsAdapter.addData(mediaAsset: data)
    }
    private func handleImagesSelection(data: [PhoneMediaAssets]) {
        data.forEach { data in
            self.attachmentsAdapter.addData(mediaAsset: data)
        }
        
    }
    
    @IBAction func didTapAddLocationButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let controller = SelectLocationController(title: "Select Location", selectedLocation: selectedLocation) { selectedLocation in
            var previousSelectedLocation : LocationModel?
            
            if (self.selectedLocation != nil) {
                previousSelectedLocation = self.selectedLocation
                let addressString = (previousSelectedLocation?.formattAdaddress ?? "") + ", " + (previousSelectedLocation?.country ?? "")
                if let index = self.locationFeelingAdapter.tags.firstIndex(of: addressString) {
                    self.locationFeelingAdapter.tags.remove(at: index)
                }
            }
            
            self.selectedLocation = selectedLocation
            let addressString = (self.selectedLocation?.formattAdaddress ?? "") + ", " + (self.selectedLocation?.country ?? "")
            self.locationFeelingAdapter.tags.append(addressString.trimmed)
            self.prepareCollectionViewFor(tags: true)
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func didTapAddEmojiButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let userEventFilter = ReusbaleOptionSelectionController(options: [PostEmojiCollection.happy.fullEmojiString, PostEmojiCollection.blessed.fullEmojiString, PostEmojiCollection.loved.fullEmojiString, PostEmojiCollection.sad.fullEmojiString, PostEmojiCollection.fantastic.fullEmojiString, PostEmojiCollection.sick.fullEmojiString, PostEmojiCollection.tired.fullEmojiString, PostEmojiCollection.heartbroken.fullEmojiString, PostEmojiCollection.fabulous.fullEmojiString, PostEmojiCollection.angry.fullEmojiString, PostEmojiCollection.down.fullEmojiString, PostEmojiCollection.safe.fullEmojiString], previouslySelectedOption: self.selectedEmoji?.fullEmojiString, screenName: "How are you feeling?", completion: { selected in
            if (selected == PostEmojiCollection.happy.fullEmojiString) {
                self.selectedEmoji = .happy
            } else if (selected == PostEmojiCollection.blessed.fullEmojiString) {
                self.selectedEmoji = .blessed
            } else if (selected == PostEmojiCollection.loved.fullEmojiString) {
                self.selectedEmoji = .loved
            } else if (selected == PostEmojiCollection.sad.fullEmojiString) {
                self.selectedEmoji = .sad
            } else if (selected == PostEmojiCollection.fantastic.fullEmojiString) {
                self.selectedEmoji = .fantastic
            } else if (selected == PostEmojiCollection.sick.fullEmojiString) {
                self.selectedEmoji = .sick
            } else if (selected == PostEmojiCollection.tired.fullEmojiString) {
                self.selectedEmoji = .tired
            } else if (selected == PostEmojiCollection.heartbroken.fullEmojiString) {
                self.selectedEmoji = .heartbroken
            } else if (selected == PostEmojiCollection.fabulous.fullEmojiString) {
                self.selectedEmoji = .fabulous
            } else if (selected == PostEmojiCollection.angry.fullEmojiString) {
                self.selectedEmoji = .angry
            } else if (selected == PostEmojiCollection.down.fullEmojiString) {
                self.selectedEmoji = .down
            } else if (selected == PostEmojiCollection.safe.fullEmojiString) {
                self.selectedEmoji = .safe
            }
            
            if (self.locationFeelingAdapter.emojiAtIndex == -1) {
                self.locationFeelingAdapter.tags.append((self.selectedEmoji?.fullEmojiString ?? "").trimmed)
                self.locationFeelingAdapter.emojiAtIndex = (self.locationFeelingAdapter.tags.count - 1)
                self.prepareCollectionViewFor(tags: true)
            } else {
                self.locationFeelingAdapter.tags.remove(at: self.locationFeelingAdapter.emojiAtIndex)
                self.locationFeelingAdapter.tags.append((self.selectedEmoji?.fullEmojiString ?? "").trimmed)
                self.locationFeelingAdapter.emojiAtIndex = (self.locationFeelingAdapter.tags.count - 1)
                self.prepareCollectionViewFor(tags: true)
            }
        })
        
        self.presentPanModal(userEventFilter)
    }
    
    @IBAction func didTapAddFileButton(_ sender: UIButton) {
        view.endEditing(true)
        
        self.selectedEvent = nil
        self.selectedGroup = nil
        self.attachmentsAdapter.removeAssets()
        DocumentPicker.shared.open(from: self) { (url) in
            self.tableView.isHidden = false
            self.tagFilesAdapter.configure()
            self.tagFilesAdapter.fileURLs.append(url)
            if url.startAccessingSecurityScopedResource() {
                print("Access granted")
            }
            if let data = try? Data(contentsOf: url) {
                let m = Media(withData: data, key: "documents", mimeType: url.mimeType(), ext: url.pathExtension)
                self.tagFilesAdapter.documentsMedia.append(m)
                self.postSelectedAttachmentType = .file
                self.tableView.reloadData()
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    @IBAction func didTapPostButton(_ sender: UIButton) {
        view.endEditing(true)
        
        let validated = validate()
        if validated {
            createPost()
        }
    }
}

// MARK: - Utlity Methods
extension NewPostController {
    func setupUI() {
        txtPost.dpTagDelegate = self // set DPTagTextViewDelegate Delegate
        txtPost.setTagDetection(false) // true :- detecte tag on tap , false :- Search Tags using mentionSymbol & hashTagSymbol.
        txtPost.mentionSymbol = "@" // Search start with this mentionSymbol.
        txtPost.hashTagSymbol = "#" // Search start with this hashTagSymbol for hashtagging.
        txtPost.allowsHashTagUsingSpace = true // Add HashTag using space
        setTextViewFont(size: 14, color: .black, placeholderColor: R.color.sub_title() ?? .lightGray)
        
    }
    
    func setTextViewFont(size: CGFloat, color: UIColor, placeholderColor: UIColor) {
        let font = UIFont.italicSystemFont(ofSize: 16)
        
        txtPost.textViewAttributes = [NSAttributedString.Key.foregroundColor: color,
                                      NSAttributedString.Key.font: font ]
        
        txtPost.mentionTagTextAttributes = [NSAttributedString.Key.foregroundColor: color,
                                            NSAttributedString.Key.backgroundColor: UIColor.green.withAlphaComponent(0.2),
                                            NSAttributedString.Key.font: font ]
        
        
        txtPost.hashTagTextAttributes = [NSAttributedString.Key.foregroundColor: R.color.buttons_green() ?? .green,
                                         NSAttributedString.Key.backgroundColor: UIColor.clear, NSAttributedString.Key.font:
                                            font ]
        txtPost.textViewDidChange(txtPost)
        lblPlaceholder.textColor = placeholderColor
        lblPlaceholder.font = UIFont.systemFont(ofSize: size, weight: .medium)
        
    }
    
    func validate() -> Bool {
        if (txtPost.text.trimmed.count == 0) || (txtPost.text.trimmed.count == 0) {
            self.showErrorWith(message: "Please add title")
            return false
        }
        return true
        
    }
}

// MARK: - TextView Delegate
extension NewPostController: DPTagTextViewDelegate {
    func dpTagTextView(_ textView: DPTagTextView, didInsertTag tag: DPTag) {
        if ((self.txtPost.text?.hasSuffix("@\(tag.name)")) != nil)  {
            tagUserTableView.isHidden = true
        }
    }
    
    func dpTagTextView(_ textView: DPTagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {
        if !isHashTag {
            if (strSearch.count == 0) {
                tagUserTableView.isHidden = true
            } else {
                tagUserTableView.isHidden = false
                tagUserAdapter.configure()
            }
            tagUserAdapter.search(text: strSearch)
        } else {
            tagUserTableView.isHidden = true
        }
    }
    func textViewDidBeginEditing(_ textView: DPTagTextView) {
        imgProfile.isHidden = true
        cstStkPlaceholderTop.constant = imgProfile.isHidden ? 16 : 16
        view.layoutIfNeeded(true)
    }
    func textViewDidEndEditing(_ textView: DPTagTextView) {
        stkPlaceholder.isHidden = textView.text.count > 0
        imgProfile.isHidden = textView.text.count > 0
        cstStkPlaceholderTop.constant = imgProfile.isHidden ? 16 : 16
        view.layoutIfNeeded(true)
    }
    func textViewDidChange(_ textView: DPTagTextView) {
        stkPlaceholder.isHidden = textView.text.count > 0
        if textView.text.last == " " {
            tagUserTableView.isHidden = true
        }
        
        if (textView.text.last == "@" && textView.text.count > 0) {
            tagUserAdapter.showAll()
            tagUserTableView.isHidden = false
        }
        
        if textView.text.count == 0 {
            tagUserTableView.isHidden = true
        }
        else{
           //
        }
        
        let max = stkToolbar.top - viewNavBar.bottom - 100
        
        if textView.frame.height >= max {
            textView.isScrollEnabled = true
        }
        
        if textView.contentSize.height < textView.frame.height {
            textView.isScrollEnabled = false
        }
    }
    
    func dpTagTextView(_ textView: DPTagTextView, didRemoveTag tag: DPTag) {
        print("[dpTagTextView didRemoveTag]")
    }
}

// MARK: - Web APIs
extension NewPostController {
    func getFriends() {
        APIManager.social.getFriendsOnly { [weak self] friends, error in
            guard let self = self else { return }
            
            if error == nil {
                self.tagUserAdapter.users = friends
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func getGroupMembers(id: String) {
        APIManager.social.getGroupDetails(groupId: id) { [weak self] (group, error) in
            guard let self = self else { return }
            
            if error == nil {
                self.tagUserAdapter.users = group?.groupMembers ?? []
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func createPost() {
        var postText = txtPost.text ?? ""
        var colors = ""
        var colorPositions = ""
        var taggedFriends = [String]()
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        
        for tag in txtPost.arrTags {
            if !tag.isHashTag {
                //postText = postText.replacingOccurrences(of: tag.name, with: "id{\(tag.id)}")
                taggedFriends.append(tag.id)
            }
        }
        
        if viewGradient.isHidden == false {
            colors = viewGradient.colors.hexStrings.joined(separator: ", ")
            colorPositions = "(\(viewGradient.startPoint.x), \(viewGradient.startPoint.y)), (\(viewGradient.endPoint.x), \(viewGradient.endPoint.y))"
        }
        
        let postTargetUsers = selectedFriends.map { $0.userID }
        
        var parameters: [String: Any] = [
            "post_name": postText,
            "background_colors": colors,
            "background_colors_position": colorPositions,
            "tag_friends": taggedFriends,
            "is_background": viewGradient.isHidden == false,
            "post_deletion_settings": selectedPostSetting.rawValue,
            "post_type": "personal",
            "privacy": selectedPostPrivacy.rawValue,
            "post_target_users": postTargetUsers
        ]
        
        if selectedGroup != nil {
            parameters["group_id"] = selectedGroup?.groupID ?? ""
            parameters["post_type"] = "groups"
        }
        
        if selectedEvent != nil {
            parameters["event_id"] = selectedEvent?.eventID
            parameters["post_type"] = "events"
        }
        
        if selectedPostPrivacy == .mySchoolOnly {
            parameters["post_type"] = "school"
        }
        
        if selectedEmoji != nil {
            parameters["feelings"] = selectedEmoji?.fullEmojiString
        }
        
        
        if let location = selectedLocation {
            parameters["country"] = location.country
            parameters["location_name"] = location.formattAdaddress
            parameters["place_id"] = location.placeId
            parameters["place_name"] = location.formattAdaddress
            parameters["latitude"] = location.latitude
            parameters["longitude"] = location.longitude
        }
        
        var attachments = [Media]()
        
        if (attachmentsAdapter.mediaCount > 0) {
            attachments = attachmentsAdapter.mediaForServer.filter { $0.data != nil }
        }
        
        if (self.tagFilesAdapter.documentsMedia.count > 0) {
            attachments = tagFilesAdapter.documentsMedia.filter { $0.data != nil }
        }
        
//        progressBar.isHidden = false
//        self.addBlurView(top: viewNavBar.bottom, bottom: 0, left: 0, right: 0)
        btnPost.startAnimation()
        print(parameters)
        if !isScreenPresentFromGroup{
            
            
            if let vcs = self.tabBarController?.viewControllers, let homeVC = (vcs[0] as? UINavigationController)?.topViewController as? HomeController{
                btnPost.stopAnimation()
                self.tabBarController?.selectedIndex = 0
                self.resetCreatePostView()
                self.view.isUserInteractionEnabled = true
                self.dismiss(animated: true) {
                    
                    homeVC.uploadNewPost(parameters, attachments)
                }
                
            }
        }
        else{
            
                    APIManager.fileUploader.createPost(parameters: parameters, media: attachments) { [weak self] progress in
                        guard let self = self else { return }
            
                        self.progressBar.progress = progress
                    } completion: { [weak self] response, error in
                        guard let self = self else { return }
            
                        self.progressBar.isHidden = true
                        self.btnPost.stopAnimation()
                        self.removeBlurView()
            
                        self.view.isUserInteractionEnabled = true
                        if error == nil {
                            self.dismiss(animated: true, completion: nil)
                            self.resetCreatePostView()
                            if let vcs = tabBarController?.viewControllers{
            
                                if let homeVC =  (vcs[0] as? UINavigationController)?.topViewController as? HomeController{
                                    homeVC.getPosts(limit: homeVC.adapter.posts.count > 0 ? homeVC.adapter.posts.count : 5, reload: true)
                                }
            
                            }
            
                            self.tabBarController?.selectedIndex = 0
                        } else {
                            self.showErrorWith(message: error!.message)
                        }
                    }
        }
    }
}

extension NewPostController : PostPrivacyDropDownProtocol {
    func groupSelected(group: Group?) {
//        self.presentedViewController?.dismiss(animated: true)
        if (group != nil) {
            self.selectedEvent = nil
            self.selectedGroup = group!
            self.tagGroupAdapter.group = [self.selectedGroup!]
            self.tagGroupAdapter.configure()
            self.tableView.isHidden = false
            self.tableView.reloadData()
            self.setSettingName(PostPrivacy.groups)
        } else {
            self.selectedGroup = nil
            self.tableView.isHidden = true
        }
        
    }
    
    func friendPrivacy(_ settings: PostPrivacy, _ friends: [User]) {
        self.selectedFriends = friends
        self.setSettingName(settings)
        self.resetGroup()
    }
    
    func resetGroup() {
        self.selectedGroup = nil
        self.tagGroupAdapter.group = []
        self.tableView.isHidden = true
    }
    
    func setSettingName(_ settings: PostPrivacy) {
        self.selectedPostPrivacy = settings
        self.lblPostPrivacy.text = settings.name
    }
}


extension NewPostController : EDImagePickerDelegate{
    func imagePickerHasNoItemsInLibrary(_ picker: EDImagePicker) {
        print("#function 1")
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        print("#function 2")
        return true
    }
}

