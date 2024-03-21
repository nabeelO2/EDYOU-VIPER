//
//  SocialManager.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation

class SocialManager {
    let manager = APIBaseManager()
}

// MARK: - Stories
extension SocialManager {
    func getHomeStories(skip: Int, limit: Int, completion: @escaping (_ stories: [Story], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.stories.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[StoriesData]>.self) { response, error in
                    let data = response?.data.stories()
                    completion(data ?? [], error)
                    
                }
            } else {
                completion([], error)
            }
        }
    }
}
//MARK: - Leader
extension SocialManager{
    func getLeader(tag: Int? = nil,completion: @escaping (_ leaders: LeaderFilter?, _ error: ErrorResponse?) -> Void) {
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                
                var parameters: [String: Any] = [
                    "leader_board_type" : "friends"
                ]
//                "worldwide",
//                 "national",
//                 "college",
//                  "friends"
                if let tag = tag, tag == 1, let schoolId = Cache.shared.user?.schoolID {
                    parameters["school_id"] = schoolId
                    parameters["leader_board_type"] = "college"
                }
                else if let tag = tag, tag == 2 {
                    parameters["leader_board_type"] = "national"
                    parameters["country"] = "usa"
                }
                
                let url = Routes.leader.url(parameters)!
                
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<LeaderFilter>.self) { response, error in
                    
                    let leader = response?.data
                    
                    completion(leader, error)
                    
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getLeaderwithFilter(type: LeaderBoardTypeFilter? = .national,filter: LeaderBoardPeriodFilter? = .all,completion: @escaping (_ leaders: LeaderFilter?, _ error: ErrorResponse?) -> Void) {
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                
                var parameters: [String: Any] = [
                    "leader_board_type" : "friends"
                ]
                if type == .school {
                    parameters["leader_board_type"] = "college"
                    let schoolId = Cache.shared.user?.schoolID  ?? "64b24e3b35832359f705bacc"
                    parameters["school_id"] = schoolId
                }
                else if type == .national{
                    parameters["leader_board_type"] = "national"
                    parameters["country"] = "usa"
                }
                else{//friends
                    
                }
                
                
                let filterby = filter?.rawValue
                parameters["leader_board_period"] = filterby
                
                let url = Routes.leader.url(parameters)!
                print("#Leader : \(url.absoluteString)")
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<LeaderFilter>.self) { response, error in
                    
                    let leader = response?.data
                    
                    completion(leader, error)
                    
                }
            } else {
                completion(nil, error)
            }
        }
    }
}
// MARK: - Posts
extension SocialManager {
    func getHomePosts(userId: String? = nil, groupId: String? = nil, postType: PostType, skip: Int, limit: Int, completion: @escaping (_ posts: Posts?, _ error: ErrorResponse?) -> Void) {
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var parameters: [String: Any] = [
                    "post_type": postType.rawValue,
                    "skip": skip,
                    "limit": limit
                ]
                
                if let id = userId, id != Cache.shared.user?.userID {
                    parameters["user_id"] = id
                }
                if let id = groupId {
                    parameters["group_id"] = id
                }
                let url = Routes.posts.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Posts>.self) { response, error in
                    
                    let data = response?.data
                    
                    data?.posts?.setIsReacted()
                    data?.posts?.updateMediaArray()
                    data?.posts?.updateTheHidePostStatus()
                    completion(data, error)
                    
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getPosts(userId: String? = nil, groupId: String? = nil, skip: Int, limit: Int, completion: @escaping (_ posts: Posts?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var parameters: [String: Any] = [:]
                if let id = userId, id != Cache.shared.user?.userID {
                    parameters = ["user_id": id]
                }
                
                let url = Routes.posts.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Posts>.self) { response, error in
                    var data = response?.data
                    data?.posts?.setIsReacted()
                    data?.posts?.updateMediaArray()
                    completion(data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getPostDetails(postId: String, commentId: String = "", completion: @escaping (_ post: Post?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = commentId.isEmpty ?  Routes.post.url(addPath: "/\(postId)")! :
                Routes.post.url(addPath: "/comment/\(commentId)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Post>.self) { response, error in
                    
                    var p = response?.data
                    p?.setIsReacted()
                    p?.setCommentsIsLiked()
                    p?.updateMediaArray()
                    
                    completion(p, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func addReaction(postId: String, isAdd: Bool, reaction: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.post.url(addPath: "/\(postId)/likes?is_liked=\(isAdd)")!
                
                let parameters: [String: Any] = [
                    "like_emotion": reaction
                ]
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func like(postId: String, isLiked: Bool, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.post.url(addPath: "/\(postId)/likes?is_liked=\(isLiked)")!
                
                let parameters: [String: Any] = [
                    "like_emotion": "like"
                ]
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func addComment(postId: String, commentId: String?, type: CommentType,  parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ result: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var updatedParam = parameters
                
                var queryParameters: [String: Any] = [
                    "comment_type": type.rawValue
                ]
                if let id = commentId {
                    queryParameters["comment_id"] = id
                }
                let url = Routes.post.url(addPath: "/\(postId)/comment", parameters: queryParameters)!
               
                
                if media.count > 0 {//upload media first
                     FileUploader().uploadMedia(media: media, progress: progress) { user, error in
        //                print(user)
                        var videoURLs = [String]()
                        var photoURLs = [String]()
                        
                        if ((media.first?.videoURL) == nil) {
                            user?.results?.forEach({ obj in
                                if let url = obj.url{
                                    photoURLs.append(url)
                                }
                                
                            })
                            updatedParam["images"] = photoURLs
                        }
                        else{
                            user?.results?.forEach({ obj in
                                if let url = obj.url{
                                    videoURLs.append(url)
                                }
                                
                            })
                            updatedParam["videos"] = videoURLs
                        }
                        
                        
                        
                        upload(parameters: updatedParam)
                    }


                }
                else{
                    upload(parameters: updatedParam)
                }
                
                
                func upload(parameters: [String: Any]){
                    self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                        completion(result?.data, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func like(postId: String, commentId: String, isLiked: Bool, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.post.url(addPath: "/\(postId)/comment/\(commentId)/likes?comment_type=parent&is_liked=\(isLiked)")!
                
                let parameters: [String: Any] = [
                    "like_emotion": "like"
                ]
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func like(postId: String, commentId: String, isLiked: Bool, type: CommentType , emoji: String , completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.post.url(addPath: "/\(postId)/comment/\(commentId)/likes?comment_type=\(type.rawValue)&is_liked=\(isLiked)")!
                
                let parameters: [String: Any] = [
                    "like_emotion": emoji
                ]
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func deletePost(id: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.post.url(addPath: "/\(id)")!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func deleteComment(postId: String, comment: Comment, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        guard let commentId = comment.commentID else { return }
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var url = Routes.post.url(addPath: "/\(postId)/comment?comment_type=\(comment.commentType.rawValue)&parent_comment_id=\(commentId)")!
                if let parentId = comment.parentCommentId , comment.commentType == .child {
                    url = Routes.post.url(addPath: "/\(postId)/comment?comment_type=\(comment.commentType.rawValue)&parent_comment_id=\(parentId)&child_comment_id=\(commentId)")!
                }
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}


// MARK: - Search
extension SocialManager {
    func getAllUsers(completion: @escaping (_ user: [User], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.profiles.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Profiles>.self) { response, error in
                    completion(response?.data.profiles ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
}

// MARK: - Friends
extension SocialManager {
    func getFriendshipStatus(userId: String, completion: @escaping (_ user: FriendShipStatusModel?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.status.url(["user_id": userId])!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<FriendShipStatusModel>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getSentRequests(completion: @escaping (_ user: [User], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.friends.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchFriends>.self) { response, error in
                    completion(response?.data.friends ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
    func getFriends(userId: String? = nil, completion: @escaping (_ user: SearchFriends?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var url = Routes.friends.url()!
                if let u = userId, u != Cache.shared.user?.userID {
                    url = Routes.friends.url(["user_id": u])!
                }
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchFriends>.self) { response, error in
                    if let f = response?.data {
                        if Cache.shared.user?.userID == userId {

                            var allUsers:[User] = (f.friends ?? [])
                            allUsers.append(contentsOf: f.blockedusers ?? [])
                            allUsers.append(contentsOf: f.pendingFriends ?? [])
                            allUsers.append(contentsOf: f.rejectedFriends ?? [])
                            Cache.shared.frinedDict = allUsers.reduce(into: [String: [String]]()) { result, user in
                                result["\(user.userID ?? "")@ejabberd.edyou.io"] = [user.name?.completeName ?? user.formattedUserName,user.profileImage ?? ""]
                            }

                        }
                    }
//                    if let friends = response?.data{
//                        FriendManager.shared.savefriendLocally(searchfriends: friends)
//                    }
//                   
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getFriendsOnly(completion: @escaping (_ user: [User], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.friends.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchFriends>.self) { response, error in
                    if let users = response?.data.friends {
                        users.forEach{
                            DBRosterStore.instance.addFrindToRoster(userID: $0.userID ?? "", userName: $0.name?.completeName ?? "")
                        }
                    }
                    completion(response?.data.friends ?? [], error)
                    
                }
            } else {
                completion([], error)
            }
        }
    }
    func sendFriendRequest(user: User, message: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {

        DBRosterStore.instance.addFrindToRoster(userID: user.userID ?? "", userName: user.name?.completeName ?? "")
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.friendRequest.url()!
                let parameters: [String: Any] = [
                    "user_id": user.userID ?? "",
                    "message": message
                ]
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<FriendRequestSent>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func updateFriendRequestStatus(user: User, status: FriendRequestStatus, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        if status == .approved {
            DBRosterStore.instance.addFrindToRoster(userID: user.userID ?? "", userName: user.name?.completeName ?? "")
        } else if status == .rejected {
            DBRosterStore.instance.removeFrindToRoster(userID: user.userID ?? "")
        }
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.updateFriendRequest.url()!
                
                let parameters: [String: Any] = [
                    "user_id": user.userID ?? "",
                    "friend_request_status": status.rawValue
                ]
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<FriendRequestStatusReceived>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
        
    }
    func unFriend(userId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.unfriend.url(addPath: "/\(userId)/unfriend")!
                
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<FriendRequestStatusReceived>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
}

// MARK: - Group
extension SocialManager {
    
    func createGroup(parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var updatedParam = parameters
                let url = Routes.group.url()!
                
                if media.count > 0 {//upload media first
                     FileUploader().uploadMedia(media: media, progress: progress) { user, error in
        //                print(user)
                         let url = user?.results?.first?.url ?? ""
                         var photoURLs : String = url
                         
                         updatedParam["group_icon"] = photoURLs
                        upload(parameters: updatedParam)
                    }


                }
                else{
                    upload(parameters: updatedParam)
                }
                
                
                func upload(parameters: [String: Any]){
                    self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                        completion(result?.data, error)
                    }
                }
//                self.manager.upload(url: url, requestType: .post, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
//                    completion(response?.data, error)
                
            } else {
                completion(nil, error)
            }
        }
    }
    func getGroups(userId: String? = nil, completion: @escaping (_ my: [Group], _ joined: [Group], _ invited: [Group], _ pending: [Group], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var parameters: [String: Any] = [:]
                if let id = userId, id.count > 0 {
                    parameters = ["user_id": id]
                }
                let url = Routes.groups.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<GroupsData>.self) { response, error in
                    let my = (response?.data.my ?? []).groups
                    let joined = (response?.data.joined ?? []).groups
                    let invited = (response?.data.invited ?? []).groups
                    let pending = (response?.data.pending ?? []).groups
                    completion(my, joined, invited, pending, error)
                }
            } else {
                completion([], [], [], [], error)
            }
        }
    }
    func getGroupDetails(groupId: String, completion: @escaping (_ user: Group?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Group>.self) { response, error in
                    
                    let group = response?.data
                    group?.groupPosts?.posts?.setIsReacted()
                    group?.groupPosts?.posts?.updateMediaArray()
                    completion(group, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getAdminData(groupId: String, completion: @escaping (_ user: GroupAdminData?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/admin")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<GroupAdminData>.self) { response, error in
                    var group = response?.data
                    group?.pendingPosts?.setIsReacted()
                    group?.pendingPosts?.updateMediaArray()
                    completion(group, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func groupAdminAction(groupId: String, userId: String, action: GroupAdminAction, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "user_id": userId
                ]
                
                let url = Routes.group.url(addPath: "/\(groupId)/admin/\(action.rawValue)", parameters: parameters)!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func updateGroupPost(groupId: String, postId: String, action: GroupAdminAction, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "post_id": postId
                ]
                
                let url = Routes.group.url(addPath: "/\(groupId)/admin/\(action.rawValue)", parameters: parameters)!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func deleteGroup(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/admin/delete_group")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func leaveGroup(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/user/leave")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func inviteFriend(groupId: String, userId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/user/invite/\(userId)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func joinGroup(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/user/join")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func acceptGroupInvite(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/user/accept_invite")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func rejectGroupInvite(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/user/reject_invite")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
        
    }
    
    func getGroupFriends(groupId: String, completion: @escaping (_ user: GroupFriends?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/friends")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<GroupFriends>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getGroupMedia(groupId: String, completion: @escaping (_ user: GroupMedia?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/gallery")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<GroupMedia>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    func editGroup(groupId: String, parameters: [String: Any] = [:], media: [Media] = [], progress: ((_ progress: Float) -> Void)? = nil, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.group.url(addPath: "/\(groupId)/edit")!
                var updatedParam = parameters
                if media.count > 0 {//upload media first
                     FileUploader().uploadMedia(media: media, progress: progress) { user, error in
        //                print(user)
                         let url = user?.results?.first?.url ?? ""
                         var photoURLs : String = url

                         updatedParam["group_icon"] = photoURLs
                        upload(parameters: updatedParam)
                    }


                }
                else{
                    upload(parameters: updatedParam)
                }
                
                
                func upload(parameters: [String: Any]){
                    
                    self.manager.putRequest (url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                        completion(error)
                    }
                }
                
//                self.manager.upload(url: url, requestType: .put, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { result, error in
//                    completion(error)
//                }
            } else {
                completion(error)
            }
        }
    }
    
}

// MARK: - Favorite
extension SocialManager {
    func addToFavorite(type: FavoriteType, id: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "action": "add",
                    "fav_type": type.rawValue,
                    "favourite_id": id
                ]
                let url = Routes.favourites.url(parameters)!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func removeFromFavorite(type: FavoriteType, id: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "action": "remove",
                    "fav_type": type.rawValue,
                    "favourite_id": id
                ]
                
                let url = Routes.favourites.url(parameters)!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func getFavorites(type: FavoriteType, completion: @escaping (_ favorites: Favorites?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "fav_type": type.rawValue,
                ]
                let url = Routes.favourites.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Favorites>.self) { response, error in
                    var data = response?.data
                    completion(data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Block
extension SocialManager {
    
    func addBlockUser( userid: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "blocked_user_id": userid
                ]
                let url = Routes.blockedUser.url()!
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func removeBlockUser(userid: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "blocked_user_id": userid
                ]
                
                let url = Routes.blockedUser.url(parameters)!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: parameters, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
//    func getBlockUserlist( completion: @escaping (_ user: Friends?, _ error: ErrorResponse?) -> Void) {
//        APIManager.shared.refreshTokenIfRequired { error in
//            if error == nil {
////                let parameters: [String: Any] = [
////                    "fav_type": type.rawValue,
////                ]
//                let url = Routes.blockedUser.url()!
//                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<Friends>.self) { response, error in
//                    let data = response?.data
//                    completion(data, error)
//                }
//            } else {
//                completion(nil, error)
//            }
//        }
//    }
    
    func getBlockUserlist( completion: @escaping (_ user: SearchFriends?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.blockedUser.url()!
//                if let u = userId, u != Cache.shared.user?.userID {
//                    url = Routes.friends.url(["user_id": u])!
//                }
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchFriends>.self) { response, error in
//                    if let f = response?.data {
//                        Cache.shared.friends = f
//                    }
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Event
extension SocialManager {
    
    func createEvent(parameters: [String: Any], eventId: String?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var url = Routes.events.url()!
                if let eventId = eventId {
                    url = Routes.events.url(addPath: "/\(eventId)")!
                    self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: GeneralResponse.self, completion: completion)
                } else {
                    self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: GeneralResponse.self, completion: completion)
                }
               
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getMyEvents(query: EventQuery, userId: String? = nil, completion: @escaping (_ eventsIAmGoing: [Event]?, _ eventsICreated: [Event]?, _ eventsIAmNotGoing: [Event]?, _ eventsIAmInvited: [Event]?, _ eventsIAmInterested: [Event]?, _ error: ErrorResponse?) -> Void) {
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var url = Routes.events.url(addPath: "/me")!
                if let id = userId, !(Cache.shared.user?.userID!.elementsEqual(id) ?? false)  {
                    url = Routes.events.url(addPath: "/me?user_id=\(id)")!
                }
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: MyEvents.self) { response, error in
                    let eventsIAmGoing = response?.data?.eventsIAmGoing?.events()
                    let eventsICreated = response?.data?.eventsICreated?.events()
                    let eventsIAmNotGoing = response?.data?.eventsIAmNotGoing?.events()
                    let eventsIAmInvited = response?.data?.eventsIAmInvited?.events()
                    let eventsIAmInterested = response?.data?.eventsIAmInterested?.events()
                    completion(eventsIAmGoing, eventsICreated, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested, error)
                }
            } else {
                completion(nil, nil, nil, nil, nil, error)
            }
        }
    }
    
    func getEvents(query: EventQuery, userId: String? = nil, completion: @escaping (_ events: [Event]?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                if query == .me {
                    var url = Routes.events.url(addPath: "/me?skip_old_events = true")!
                    if let id = userId, !(Cache.shared.user?.userID!.elementsEqual(id) ?? false)  {
                        url = Routes.events.url(addPath: "/me?user_id=\(id)")!
                    }
                    self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<MyEventsDataModel>.self) { response, error in
                        let events = response?.data.eventsICreated?.events()
                        completion(events, error)
                    }
                } else {
                    
                    let url = Routes.events.url(["privacy": query.rawValue])!
                    self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: Events.self) { response, error in
                    
                        let events = response?.data?.events()
                        completion(events, error)
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getCalendarEvents(completion: @escaping (_ events: [Event], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.calenderEvents.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[Event]>.self) { response, error in
                    var events = response?.data
                    events?.updateTitleAndEventName()
                    completion(events ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
    
    func updateEvent(eventId: String, parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.events.url(addPath: "/\(eventId)")!
                
                self.manager.upload(url: url, requestType: .put, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: GeneralResponse.self, progress: progress) { response, error in
                    completion(response, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func eventAction(eventId: String, action: EventAction, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.events.url(addPath: "/\(eventId)/interest", parameters: ["event_action": action.rawValue])!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func inviteFriends(eventId: String, friendsIds: [String], completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.events.url(addPath: "/\(eventId)/interest", parameters: ["event_action": EventAction.invite.rawValue])!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: ["user_ids": friendsIds], parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func eventDetails(eventId: String, completion: @escaping (_ event: EventBasic?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.events.url(addPath: "/\(eventId)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<EventBasic>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func deleteEvent(eventId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.events.url(addPath: "/\(eventId)")!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: GeneralResponse.self) { (response, error) in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    
    func addEventToCalendar(data: Event, completion: @escaping (_ response: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.calenderEvent.url()!
                
                var parameters = [String: Any]()
                
                if let title = data.title ?? data.eventName {
                    parameters["title"] = title
                }
                if let eventDescription = data.eventDescription {
                    parameters["description"] = eventDescription
                }
                if let location = data.location {
                    parameters["location"] = location
                }
                if let startTime = data.startTime {
                    parameters["start_time"] = startTime
                }
                if let endTime = data.endTime {
                    parameters["end_time"] = endTime
                }
                
                if let shareWith = data.shareWith {
                    parameters["share_with"] = shareWith
                }
                if let eventPrivacy = data.eventPrivacy {
                    parameters["privacy"] = eventPrivacy
                }
                
                parameters["show_me_as"] = ShowMeAs.busy.rawValue
                
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .httpUrlEncode, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
}

// MARK: - Marketplace
extension SocialManager {
    func getAds(query: String, category: MarketplaceCategory,  completion: @escaping (_ event: [MarketProductAd], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.marketplaceAds.url(["q": query, "category": category.rawValue])!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[MarketProductAd]>.self) { response, error in
                    completion(response?.data ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
    func getSavedAds(completion: @escaping (_ event: [MarketProductAd], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.marketplaceLikedAds.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[MarketProductAd]>.self) { response, error in
                    completion(response?.data ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
    func likeAd(adId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.marketplaceAd.url(addPath: "/\(adId)/like")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func unLikeAd(adId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.marketplaceAd.url(addPath: "/\(adId)/unlike")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}

// MARK: - Chat
extension SocialManager {

    func CallChatRoom(roomId: [String],callType: CallType,roomJID:String, completion: @escaping (_ chatCall: ChatCall?,  _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.chatRoomCall.url()!//.url(addPath: "/\(roomId)?call_type=\(callType.rawValue)")!
                #if DEBUG
                print("URL == >>  \(url)")
                #endif
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: ["receiver_ids": roomId,"call_type": callType.rawValue,"room_jis":roomJID,"room_jid":roomJID], parameterType: .raw, resultType: SuccessResponse<ChatCall>.self)
                { response, error in
                    let chatCall = response?.data
                    completion(chatCall, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func EndCallChatRoom(roomId: String, completion: @escaping (_ chatCall: ChatCall?,  _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.chatRoomCall.url(addPath: "/\(roomId)")!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: ["room_id": "\(roomId)"], resultType: SuccessResponse<ChatCall>.self) { response, error in
                    var chatCall = response?.data
                    completion(chatCall, error)
                }
 
            } else {
                completion(nil, error)
            }
        }
    }
    
    func sendChatImages(roomId: String, parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: FileUploadResponseNew?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                
                let url = Routes.fileUpload.url()
                
                self.manager.upload(url: url!, requestType: .post, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: FileUploadResponseNew.self, progress: progress) { response, error in
                    completion(response, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func sendChatDocuments(roomId: String, media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: FileUploadResponseNew?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.fileUpload.url()
                
                self.manager.upload(url: url!, requestType: .post, headers: APIManager.shared.header,parameters: [:], media: media, resultType: FileUploadResponseNew.self, progress: progress) { response, error in
                    completion(response, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func sendChatAudio(roomId: String, media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: FileUploadResponseNew?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.fileUpload.url()
                
                self.manager.upload(url: url!, requestType: .post, headers: APIManager.shared.header,parameters: [:], media: media, resultType: FileUploadResponseNew.self, progress: progress) { response, error in
                    completion(response, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}


//MARK: - Notifications
extension SocialManager{
    func getNotifications(completion: @escaping (_ event: [NotificationData], _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notifications.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[NotificationData]>.self) { response, error in
                    completion(response?.data ?? [], error)
                }
            } else {
                completion([], error)
            }
        }
    }
    func updateNotificationSettings(parameters: [String: Any], id: String,completion: @escaping (_ event: NotificationsSettingData?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notificationsSettings.url()!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, resultType: SuccessResponse<NotificationsSettingData>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getNotificationSettings(completion: @escaping (_ event: NotificationsSettingData?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notificationsSettings.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<NotificationsSettingData>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func readNotifications(id: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notifications.url(addPath: "/\(id)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    func readSelectedNotifications(parameters: [String : Any], completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notifications.url()!
                
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func deleteNotifications(id: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notifications.url(addPath: "/\(id)")!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }

    func deleteAllNotifications(ids: [String], completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.notifications.url()!
                let parameters = ["notification_ids" : ids] as! [String : Any]
                
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: parameters, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }

    
}


//MARK: - Invite
extension SocialManager{
    func getInvitedUser(completion: @escaping (_ invites: InvitedUsers?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.inviteUser.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<InvitedUsers>.self) { response, error in
                    let data = response?.data
                    completion(data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func inviteUser(_ parameters: [String: Any], completion: @escaping (_ invitedUser: InvitedUserResponse?,_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.inviteUser.url()!
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType : .raw, resultType: SuccessResponse<InvitedUserResponse>.self) { result, error in
                   // print(result,error)
                    completion(result?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func updateInviteStatus(_ parameters: [String: Any], completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
//                Constants.baseURL = "https://sanitas.serveo.net"
                let url = Routes.inviteUser.url(parameters)!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
//                    Constants.baseURL = "https://8172-182-180-126-38.ngrok-free.app"
                }
            } else {
                completion(error)
            }
        }
    }
}
