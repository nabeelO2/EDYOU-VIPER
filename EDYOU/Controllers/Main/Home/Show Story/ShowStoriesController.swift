//
//  ShowStoriesController.swift
//  EDYOU
//
//  Created by  Mac on 05/10/2021.
//

import UIKit
import IQKeyboardManagerSwift
import Lottie

class ShowStoriesController: BaseController {

    @IBOutlet weak var clvStories: UICollectionView!
    @IBOutlet weak var sendBtnTf: UIButton!
    @IBOutlet weak var emojiBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentLbl : UILabel!
    @IBOutlet weak var likesLbl : UILabel!
    @IBOutlet weak var likeBtn : UIButton!
    @IBOutlet weak var commentBtn : UIButton!
    @IBOutlet weak var animationBgV : UIView!
    @IBOutlet weak var bottomBgV : UIView!
    @IBOutlet  var shadowBgVs : [UIView]!
    @IBOutlet weak var reactionLbl : UILabel!
    @IBOutlet weak var angryBtn : UIButton!
    @IBOutlet weak var heartTopBtn : UIButton!
    @IBOutlet  var selectedEmojiVs : [UIView]!
    @IBOutlet weak var angryBGV : UIView!
    @IBOutlet weak var moneyBGV : UIView!
    @IBOutlet weak var likeBGV : UIView!
    @IBOutlet weak var smileBGV : UIView!
    @IBOutlet weak var nextBGV : UIView!
    @IBOutlet weak var prevBGV : UIView!
    @IBOutlet weak var reactionStack : UIStackView!
    @IBOutlet weak var msgSendTf: UITextField! {
        didSet {
            msgSendTf.delegate = self
        }
    }
    @IBOutlet weak var tapBGV : UIView!
    
    var stories = [Story]()
    var adapter: ShowStoriesAdapter!
    
    var selectedIndex = 0
    var currentStoryIndex = 0{
        didSet{
            
            updateComments()
        }
    }

    var layoutFirstTime = true

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = ShowStoriesAdapter(collectionView: clvStories)
        setupUI()
        adapter.stories = stories
        layoutFirstTime = true
        addSwipeDownGesture()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        if clvStories != nil {
//        self.clvStories.removeFromSuperview()
//        }
    }
    //693234
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       

    }
    @IBAction func addHeartTapped(_ sender: UIView) {
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0.0
        }) { [weak self] (completed) in
            // This completion block is called when the fade-in animation finishes.
            
            // Fade Out Animation
            UIView.animate(withDuration: 0.3) {
                sender.alpha = 1.0
            }
            
            self?.addHeartReaction()
        }
        
        
        
    }
    
    func addHeartReaction(){
        let isAdd = !(likeBtn.tag == 1)//img != UIImage(named: "heartFill")
        guard let postId = getCurrentPost()?.postID else{return}
        let reaction = "🩷"
        APIManager.social.addReaction(postId: postId, isAdd: isAdd, reaction: reaction) { [weak self] (error) in
            guard let self = self else { return }
            if error == nil {
                
                getPostDetails(postId: postId) { post in
                    if let index = self.getPostIndex(post?.postID ?? ""){
                        self.stories[self.selectedIndex].stories[index] = post!
                        self.updateComments()
                    }
                }
            }
        }
    }
    func addEmojiReaction(_ emoji : String){
        
       let postId = stories[selectedIndex].stories[currentStoryIndex].postID
        
        APIManager.social.addReaction(postId: postId, isAdd: true, reaction: emoji) { [weak self] (error) in
            guard let self = self else { return }
            if error == nil {
                
                getPostDetails(postId: postId) { post in
                    if let index = self.getPostIndex(post?.postID ?? ""){
                        self.stories[self.selectedIndex].stories[index] = post!
                        self.updateComments()
                    }
                   
                }

                
                
//                self.parent?.showErrorWith(message: error!.message)
//                if isAdd {
//                    self.posts[indexPath.row].removeReaction(reaction)
//                } else {
//                    self.posts[indexPath.row].addReaction(reaction)
//                }
//                cell.updatePostData(data: self.posts[indexPath.row])
                //                cell.addReaction(self.posts[indexPath.row].myReaction, totalReactions: self.posts[indexPath.row].totalLikes ?? 0)
            }
        }
        
        
//        APIManager.social.like(postId: postId, commentId: "", isLiked: true, type: .parent, emoji: emoji) { error in
//            if error == nil {
//
//            }
//
//        }
        
    }
    @IBAction func addReactionTapped(_ sender: Any) {
//        self.adapter.openEmojiController()
        if let post = getCurrentPost(){
            self.adapter.pauseStory()
            
            getPostDetails(postId: post.postID) { obj in
                if let post = obj{
                    if let reaction = post.reactions{
                        self.showAllReactions(emojis: reaction) {
                            self.adapter.resumeStory()
                        }
                    }
                    else{
                        self.adapter.resumeStory()
                    }

                }

            }

        }
        
                
    }
    
    @IBAction func openCommentSection(_ sender: Any) {
        adapter.pauseStory()
        if (stories[selectedIndex].stories.count <= currentStoryIndex) || selectedIndex < 0 || currentStoryIndex < 0{
            return
        }
        
        let post = self.stories[selectedIndex].stories[currentStoryIndex]
        let controller = ShowCommentsController(post: post, prefilledComment: nil)
        controller.closeCallback = {
            self.adapter.resumeStory()
        }
        presentPanModal(controller)
        
    }
    @IBAction func sendStoryTapped(_ sender: Any) {
        //MARK: To be implemented
//        print(#function)
        let message = msgSendTf.text ?? " "
        
        var parameters: [String: Any] = [
            "message": message,
        ]
        let media = [Media]()
//        if let img = commentImage, let m = Media(withImage: img, key: "images") {
//            media.append(m)
//        }
        
        let postID = self.stories[selectedIndex].stories[currentStoryIndex].postID
        APIManager.social.addComment(postId: postID, commentId: nil, type: .parent, parameters: parameters, media: media) { progress in
            print("progress : \(progress)")
        } completion: { result, error in
//            print("result : \(result)")
        }

        
        ///
        ///
//        let controller = PostPrivacyDropDownController(selectedPrivacy: .friends) { setting, friends in
////            self.selectedFriends = friends
////            self.selectedPostPrivacy = setting
////            self.lblPostPrivacy.text = setting.name
//        }
//        self.present(controller, animated: true, completion: nil)
    }
    
    
    func addSwipeDownGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
       if gesture.direction == .right {
            print("Swipe Right")
       }
       else if gesture.direction == .left {
            print("Swipe Left")
       }
       else if gesture.direction == .up {
            print("Swipe Up")
       }
       else if gesture.direction == .down {
           self.navigationController?.dismiss(animated: true)
       }
    }

    
    @IBAction func closeAction() {
        dismiss(animated: true)

    }
    
    @IBAction func showBottomActionSheet() {
        
        self.adapter.pauseStory()
        var sheetActions: [String]?
//        let UserID = stories[selectedIndex].user.userID
       // let cacheUserID = Cache.shared.user?.userID
        if selectedIndex >= stories.count{
            return
        }
        let isUserMe = stories[selectedIndex].user.isMe
            if isUserMe {
                sheetActions =  ["View Profile","Delete"]
            } else {
                sheetActions =  ["View Profile","Report"]
            }

        showActionSheet(story: stories[selectedIndex], sheetOptions: sheetActions!)
    }
    
    @IBAction func addReaction(_ sender : UIButton){
        
        
        
//        switch sender.tag {
//        case 3://angry
//            actionWithAnimation(angryBGV, emoji: "😡")
//
//            break
//
//        case 4://money
//            actionWithAnimation(moneyBGV, emoji: "🤑")
//            break
//
//        case 2://smile
//            actionWithAnimation(smileBGV, emoji: "😆")
//            break
//
//        case 5:
            self.adapter.openEmojiController()
//            break
//
//        case 1://like
//            actionWithAnimation(likeBGV, emoji: "👍")
//            break
//        default:
//            return
//        }
        
        return
        
        
        func actionWithAnimation(_ view : UIView, emoji : String){
            
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 0.0
            }) { [weak self] (completed) in
                // This completion block is called when the fade-in animation finishes.
                
                // Fade Out Animation
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1.0
                }
                
                self?.addEmojiReaction(emoji)
            }
        }

        
        
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if layoutFirstTime {
            layoutFirstTime = false
            clvStories.contentOffset.x = clvStories.frame.width * CGFloat(selectedIndex)
        }
        
    }
    func setupUI()
    {
        
        didTapGuesture()
        
        addEmojiAnimation(to: angryBGV,"angryAnim")
        addEmojiAnimation(to: smileBGV,"smile")
        addEmojiAnimation(to: likeBGV,"like")
        addEmojiAnimation(to: moneyBGV,"money")
        
        
        angryBtn.bringSubviewToFront(angryBtn)
//        reactionStack.bringSubviewToFront(heartTopBtn)
        
        shadowBgVs.forEach { view in
//            view.addShadow(ofColor: UIColor.gray, radius: 5.0, offset: CGSize(width: 1, height: 1), opacity: 0.8)
        }
        
        
        
        msgSendTf.attributedPlaceholder = NSAttributedString(
            string: "Comment",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        updateComments()
        addLongPressGuesture()
    }
    
    private func addLongPressGuesture(){
    
        animationBgV.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:))))
    }
    private func didTapGuesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        animationBgV.addGestureRecognizer(tap)
        
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        nextBGV.addGestureRecognizer(nextTap)
        
        let prevTap = UITapGestureRecognizer(target: self, action: #selector(prevTapped))
        prevBGV.addGestureRecognizer(prevTap)
        
    }
    @objc func doubleTapped() {
        // do something here
        print("double tap")
//        addHeartAnimation()
        addHeartAnimation()
        likeBtn.tag = 0
        addHeartReaction()
        
    }
    @objc func nextTapped() {
        // do something here
//        print("next tap")
//        addHeartAnimation()
       
        if let cell = clvStories.visibleCells.first as? StoryCell{
            cell.showNextStory()
        }
    }
    
    @objc func prevTapped() {
        // do something here
//        print("prev tap")
//        addHeartAnimation()
       
        
        if let cell = clvStories.visibleCells.first as? StoryCell{
            cell.showPreviousStory()
        }
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        
        if frame.height > 0 {
            adapter.pauseStory()
            
        } else {
            adapter.resumeStory()
        }
        
    }
    
    
    deinit {
        print("ShowStoriesController deinit")
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
            
        if sender.state == .began {
            adapter.pauseStory()
            
            //                animationBgV.isChangeProgress = false
        } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            adapter.resumeStory()
            //                animationBgV.isChangeProgress = true
        }
            
        
        
    }
    
    
    private func updateComments(){
         
        guard  selectedIndex < stories.count else{
            return
        }
        if (stories[selectedIndex].stories.count <= currentStoryIndex) || selectedIndex < 0 || currentStoryIndex < 0{
            return
        }
       let totalLikes = stories[selectedIndex].stories[currentStoryIndex].totalLikes ?? 0
        let heartReaction = (stories[selectedIndex].stories[currentStoryIndex].reactions?.filter({ obj in
            obj.emoji == "🩷"
        }))?.count ?? 0
        
        likesLbl.text = "\(heartReaction)"//only heart reaction
        
        commentLbl.text = "\(stories[selectedIndex].stories[currentStoryIndex].comments?.count ?? 0)"
        reactionLbl.text = "\(totalLikes)"
        
        
        let post = stories[selectedIndex].stories[currentStoryIndex]
        if let isLiked = post.getmyReaction()?.emoji , isLiked == "🩷"{
//            likeBtn.isSelected = true
            likeBtn.tag = 1
            likeBtn.setImage(UIImage(named: "heartFill11"), for: .normal)
//
        }
        else{
            likeBtn.tag = 0
            likeBtn.setImage(UIImage(named: "heart11"), for: .normal)
        }
        fillEmojiReaction()
//        likeBtn.tintColor = .white
        
    }
    
    func fillEmojiReaction(){
        
        selectedEmojiVs.forEach { view in
            view.isHidden = true
        }
        
        
        if let post = getCurrentPost(){
            
            switch post.getmyReaction()?.emoji {
            case "😡"://angry
                 let view = selectedEmojiVs.first( where: {$0.tag == 3})
                    view?.isHidden = false
                    
                break
                
            case "🤑"://money
                
                let view = selectedEmojiVs.first( where: {$0.tag == 4})
                view?.isHidden = false
                break
                
            case "😆"://smile
                
                let view = selectedEmojiVs.first( where: {$0.tag == 2})
                view?.isHidden = false
                break
                
            
            case "👍"://like
               
                let view = selectedEmojiVs.first( where: {$0.tag == 1})
                view?.isHidden = false
                break
            default:
                return
            }
            
        }
    }
      func addHeartAnimation(){
        
        
        var animationView : LottieAnimationView = .init(name: "heart1")
          
          animationView.frame = animationBgV.bounds
          
          // 3. Set animation content mode
          
          animationView.contentMode = .scaleAspectFit
          
          // 4. Set animation loop mode
          
          animationView.loopMode = .playOnce
          
          // 5. Adjust animation speed
          
          animationView.animationSpeed = 2
          
          animationBgV.addSubview(animationView)
          
          // 6. Play animation
          
          animationView.play()
        
//        animationBgV.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            animationView.removeFromSuperview()
//            self.animationBgV.isHidden = true
        }
    }
    
    func addEmojiAnimation(to view : UIView,_ name : String){
      
      
      var animationView : LottieAnimationView = .init(name: name)
        
        animationView.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView.loopMode = .loop
        
        // 5. Adjust animation speed
        
        animationView.animationSpeed = 1
        
        view.addSubview(animationView)
        
        view.sendSubviewToBack(animationView)
        // 6. Play animation
        
        animationView.play()
      
        angryBGV.clipsToBounds = true
//        animationBgV.isHidden = false
      
     
  }
    
    func showActionSheet(story: Story, sheetOptions:[String]) {
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
         
            self.sheetButtonActions(selectedOption: selected, reportContentObject: self.getReportContentObjectWithData(story: story))
        })
      //  genericPicker.modalPresentationStyle = .overCurrentContext
        self.presentPanModal(genericPicker)

    }
    
    func sheetButtonActions(selectedOption: String, reportContentObject: ReportContent ) {
        //guard let post = posts.object(at: indexPath.row) else { return }

        adapter.resumeStory()
        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            break
        case "UnFollow":
            break
        case "View Profile":
            viewUserProfile(story: stories[selectedIndex])
        case "Report":
             moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
            deletePost(postid: reportContentObject.contentID!)
        default:
            break
        }
    }
    
    func deletePost(postid: String) {
        
        self.adapter.stopProgress()
        if currentStoryIndex >= stories[selectedIndex].stories.count{
            return
        }
        
        let deletedPost = stories[selectedIndex].stories.first(where: {$0.postID == postid})
        
        if let post = deletedPost {
            self.deletePost(post: post)
            self.navigationController?.dismiss(animated: true)
        }
       
    }
    
    
    func viewUserProfile(story: Story) {
        self.adapter.stopVideo()
        self.adapter.stopProgress()
        let controller = ProfileController(user: story.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveToReportContentScreen(reportContentObject: ReportContent) {
        let navC = self.navigationController ?? self.parent?.navigationController
        // let group = Group(groupID: groupID)
        let controller = ReportViewController(nibName: "ReportViewController", bundle: nil)
        controller.reportObject = reportContentObject
        navC?.pushViewController(controller, animated: true)
    }
    
    func getReportContentObjectWithData(story: Story) -> ReportContent {
        var reportContentObject = ReportContent()
        reportContentObject.contentID = story.stories[currentStoryIndex].postID
        reportContentObject.contentType = story.stories[currentStoryIndex].postType
        reportContentObject.userName = story.stories[currentStoryIndex].user?.name?.completeName
        reportContentObject.userID = story.stories[currentStoryIndex].userID
        return reportContentObject
    }
    
    func getPostDetails(postId id : String,onCompletion : @escaping (Post?) -> Void) {
        print("PostDetail :\\ ")
        APIManager.social.getPostDetails(postId: id,commentId: "") { post, error in
           
            if let p = post, error == nil {
//                self.post = p
                onCompletion(post)
            }
        }

        
          
    }

     func getCurrentPost()->Post?{
         if (stories[selectedIndex].stories.count <= currentStoryIndex) || selectedIndex < 0 || currentStoryIndex < 0{
             return nil
         }
       return stories[selectedIndex].stories[currentStoryIndex]
    }
    
    
    func getPostIndex(_ postId : String)->Int?{
        if let index = stories[selectedIndex].stories.firstIndex(where: { obj in
            obj.postID == postId
        }){
            return index
        }
      
        else{
            return nil
        }
   }
   
    
}
// MARK: - TextField Delegate
extension ShowStoriesController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.sendBtnTf.isHidden = false
        self.emojiBtn.isHidden = true
        self.shareBtn.isHidden = true
        self.clvStories.isUserInteractionEnabled = false
        adapter.stopProgress()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendBtnTf.isHidden = true
        self.emojiBtn.isHidden = false
        self.shareBtn.isHidden = false
        print(textField.text)
        self.clvStories.isUserInteractionEnabled = true
        textField.resignFirstResponder()
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
//        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
//        friendsAdapter.search(text: expectedText)
        
        return true
    }
}

extension ShowStoriesController {
    func deletePost(post: Post) {
       // self.startLoading(title: "")
        APIManager.social.deletePost(id: post.postID) { [self] (error) in
            if error != nil {
                
//                self.stories[selectedIndex].stories.remove(at: self.adapter.currentPage)
//                self.adapter.stories = self.stories
//                self.adapter.collectionView.reloadData()
            } else {
            }
          //  self.stopLoading()
        }
        
    }
}

