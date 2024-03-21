**Overview:**

This document will provide all the knowledge about code, how is it managed, stored and used.Starting from top level. We have the main directory in which we have three main folders. Application folder named "EDYOU", then "Pods" folder as we have 30+ pods installed. We are also adding third party packages using SPM and they are 16+

If we go inside the "EDYOU" folder we have the main "EDYOU" group, "EDYOUTests", "Products", "Pods" and "Framewords" groups.

Further more, inside the main "EDYOU" group we have "Application" folder which has the classic "AppDelegate" which includes all the boiler plate code that is executed at the every start of the app. We have pods initialization here, notifications tap actions handling, voip and device token registrations. Other than this we have another singleton class that contains all the generic level code that we use throughout the app to navigate to main modules. Then we have further two main folders named "Models" and "Controllers". Models contain all the models module-wise inside it, and controllers has all the controllers level code in it. We have some common classes in it, Auth and startup separate controllers and we have a "Main" folder inside which has the module level segregation inside it. "Main" is the more prominent and frequently used area of our code. Further we will go in detail to it and explain the code modular wise.

**Home Module:**

Home module is inside "main" folder and it has another home Folder which contains Home adapter and controller.Home adapter further contains the source class and cells used in table/collection view in this module and other xibs. The design pattern we use is adapter pattern. Every controller can be linked with one or more adapters. It has all the code related to Home Screen which has a tableview for different tabs like Public, friends etc. We are showing posts here, the Tableview is handled in "HomeAdapter". Also we are showin stories of users inside this tableview. It also has navigation towards notifications and profile. This Home screen is presented on our "main tabbar" which contains the main tabs of our app which will be explained separately.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| HomeController.xibHomeController.swift | HomeAdapter.swift | ImagePostCell.xib ImagePostCell.swift PostImageCell.xib PostImageCell.swift TextPostCell.xib TextPostCell.swift TextWithBgPostCell.xib TextWithBgPostCell.swift PostEventCell.xib PostEventCell.swift StoriesCell.xib StoriesCell.swift StoryItemCell.xib StoryItemCell.swift NoPostsCell.xib NoPostsCell.swift NoMorePostCell.xibNoMorePostCell.swift |

**Show Story Module:**

On home screen we show stories below the header tab, Clicking on it will open "ShowStoriesController" which show all the stories of the users that are uploaded that time. It has a collection view that shows these stories. The stories can be of three types image, video, or a text with background. These stories will be presented there for the specific time and then moves to next if there is not any so the view dismisses. User can also tab or swipe to change the stories as well

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| ShowStoriesController.xibShowStoriesController.swift | ShowStoriesAdapters.swift | StoryPageIndicatorCell.xib StoryPageIndicatorCell.swift StoryCell.xib StoryCell.swift
 |

**Post Detail Module:**

Inside Home group we have another post Detail folder which contains all the cells related to posts i-e ImagePostCell, TextPostCell or CommentsPostCell etc. It also has PostDetailsController which shows the detail of all the available post types i-e image, video, collection of image and video, text, or text with BG.

CommentCell is used to handle comments on posts, Comment header is just a header cell,PostDetialTextWithBGCell is the post detail cell of text with background, PostDetailtextCell is the post detail cell of text, PostDetailsImageCell is the post detail cell of image/video or there combination.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| PostDetailsController.xib PostDetailsController.swift

 | PostDetailsAdapters.swift | PostDetailTextWithBgCell.xib PostDetailTextWithBgCell.swift PostDetailsTextCell.xib PostDetailsTextCell.swift PostDetailsImageCell.xib PostDetailsImageCell.swift CommentCell.xib CommentCell.swift CommentsHeaderTableViewCell.xibCommentsHeaderTableViewCell.swift |

**U Clip Module:**

Inside the home, we also have U Clip module code classes, which have controllers, adapters, enums, Cells, etc. When we land first on the U Clip module we see ReelsViewController which shows all the U Clips inside collectionview, it has a button to go to create a new U Clip and can filter U clips by categories or add comments. When going to create a new U Clip, the class is ReelsPostViewController which has the selected clip and settings that the user can select before posting.

Clicking on the comment section will open ReelsCommentsController which opens up the comments view where the user can add comments on U Clips and can filter out categories with ReelsCategoriesViewController.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| ReelsViewController.xib ReelsViewController.swift ReelsPostViewController.xib ReelsPostViewController.swift ReelsCategoriesViewController.xib ReelsCategoriesViewController.swift ReelsCommentsController.xibReelsCommentsController.swift | ReelsAdapter.swift ReelsCommentsAdapater.swift ReelsPostAdapter.swift ReelsCategoryAdapter.swift | ReelCategoryTableViewCell.xib ReelCategoryTableViewCell.swift ReelsCollectionViewCell.xib ReelsCollectionViewCell.swift |

**Add Story Module:**

When clicking on add story from home, we enter into the module of adding story where we have two options to add a text story or a media story. Text story will have the different colors to choose option as background, in media we can add images/videos or there combination. Once select we can view them as a gallery before uploading it. AddStorController has the add story features and StoryMediaFilesController has the medias selected to upload to story.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| AddStoryController.xib AddStoryController.swift StoryMediaFilesViewController.xibStoryMediaFilesViewController.swift | StoryFontsAdapter.swiftStoryMediaFilesAdapter.swift | MediaFilesCollectionViewCell.xib MediaFilesCollectionViewCell.swift StoryFontCell.swiftStoryFontCell.xib |

**New Post Module:**

When we want to add a new post, we click on the middle button of the tab bar and click to add a new post. NewPostControlllers shows up which has the option to post as your personal or public post, post in a group, post in an event, add activity, location,feelings etc. You can also set privacy of the post.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| CreateNewController.xib CreateNewController.swift NewPostController.xib NewPostController.swift SeeAllVC.xib SeeALLVC.swift TagEvent.xib TagEvent.swift TagGroup.xib TagGroup.swift PostAllTagOptions.xibPostAllTagOptions.swift | NewPostTagUsersAdapter.swift NewPostTagFilesAdapter.swift NewPostGroupsAdapter.swift NewPostAttachmentsAdapter.swift NewPostEventsAdapter.swift ColorsBgAdapter.swift LocationAndFeelingsAdapter.swift
 | SeeAllCell.xibSeeAllCell.swift |

**Search Module:**

Search Module is one of the main tab module which is the second tab of bellow tabbar of the app. Clicking on it will open SearchDetailsController which has the ability to search posts, people, groups, events and friends. All of them has there own specific filters as well. User can redirect to specific modules on clicking the search results.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| SearchDetailsController.xibSearchDetailsController.swift | SearchDetailsAdapter.swift SearchAdapter.swift
 | Cells are reused from other modules, no new cells are related to this module. |

**Tab Bar:**

All the tabs are present in MainTabBarController.swift. All the navigation are there and some common tab bar-related methods are there as well.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| MainTabBarController.swift | N/A
 | N/A |

**Notifications Module:**

There is a button at the top right of the home screen which goes to NotifcationsController, where we have all the notifications of the app and we can navigate to specific modules from there.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| NotificationsController.xibNotificationsController.swift | NotificationsAdpater.swift
 | NotificationGeneralCell.xib NotificationGeneralCell.swift NotificationFriendRequestCell.xibNotificationFriendRequestCell.swift |

**Chat Module:**

Chat is also a major module in the app. In which we have the ability to chat one-on-one, group chat, and filter saved messages. One can send text, images, videos, documents, emojis voice notes in a chat.

As soon as you enter into this module, you will see ChatController, where you see all,friends and groups chats. Clicking on any chat will takes you to ChatRoomViewController where you have all the chat related features and messages as discussed above. Clicking on new chat NewChatController class opens up and we will different options to start a one-to-one chat with friends or a group chat. Clicking on create new group will opne ChatAddParticipant where you can add participants for the chat group. After clicking next you lands on CreateChatGroupController where after adding name, description and setting privacy you can create group by clicking on Create group button and you lands back to chatController. In group you can view group settings ChatGroupInfoController.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| ChatController.xib ChatController.swift ChatRoomController.xib ChatRoomController.swift NewChatController.xib NewChatController.swift CreateChatGroupController.xib CreateChatGroupController.swift ChatGroupInfoController.xib ChatGroupInfoController.swift ChatAddParticipantsController.xib ChatAddParticipantsController.swift ChatInfoController.xib ChatInfoController.swift ChatSearchViewController.xib ChatSearchViewController.swift UserSettingsDropDownController.xib UserSettingsDropDownController.swift AllChatReactionsController.xibAllChatReactionsController.swift | ChatAdapter.swift ChatRoomAdapter.swift ChatAttachmentAdapter.swift NewChatAdapter.swift ChatGroupInfoAdapter.swift ChatInfoAdapter.swift ChatSearchAdapter.swift UserSettingsDropDownAdapter.swift AllReactionsAdapter.swift


 | ChatRoomCell.xib ChatRoomCell.swift ChatReceivedImageCell.xib ChatReceivedImageCell.swift ChatReceivedFileCell.xib ChatReceivedFileCell.swift ChatReceivedAudioCell.xib ChatReceivedAudioCell.swift ChatReceivedTextCell.xib ChatReceivedTextCell.swift ChatSentImageCell.xib ChatSentImageCell.swift ChatSentFileCell.xib ChatSentFileCell.swift ChatSentAudioCell.xib ChatSentAudioCell.swift ChatSentTextCell.xib ChatSentTextCell.swift ChatGroupInfoCell.xib ChatGroupInfoCell.swift AddParticipantsCell.xib AddParticipantsCell.swift ImageLabelValueCell.xib ImageLabelValueCell.swift ChatSearchTypeCell.xib ​​ChatSearchTypeCell.swift ChatReactionUserCell.xib ChatReactionUserCell.swift ChatReactionEmojiCell.xibChatReactionEmojiCell.swift |

**Call Module:**

The app has the facility for audio-video calls as well. You have all the audio-video call-related features in it. There are view VCs that are used to show calling screens functionality. The main is AudioVideoCallViewController.swift which is in front when you are on call with someone. The others are minimized Call pop-ups and full-screen call pop-ups when you receive a call while you are using the app. There is also a pop-up that is active when you are on a call and doing something else in-app.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| VideoCall.xib AudioVideoCallViewController.swift CallPopup.xib CallPopup.swift FullScreenCallPopupViewController.xib FullScreenCallPopupViewController.swift OngoingCallPopup.xibOngoingCallPopup.swift | AudioVideoCallAdapter.swift


 | remoteParticipantGroupCollectionViewCell.xib remoteParticipantGroupCollectionViewCell.swift
 |

**Settings Module:**

Settings module has all the gigantic settings of the app, When going to the menu from the tab bar we have many options, and settings are one of them. When we open it we have a tableview of different settings like notifications, location, password, invite friends, posts, block users, privacy policy, and help center. All of the settings have their sub-settings screens on clicking them.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| SettingsController.xib SettingsController.swift NotificationsSettingsController.xib NotificationsSettingsController.swift ChangePasswordController.xib ChangePasswordController.swift InviteFriendsController.xib InviteFriendsController.swift PostSettingsController.xib PostSettingsController.swift BlockListController.xib BlockListController.swift PrivacyPolicyController.xib PrivacyPolicyController.swift HelpController.xib HelpController.swift MenuController.xibMenuController.swift | SettingsAdapter.swift NotificationsSettingsAdapter.swift PostSettingsAdapter.swift BlockListAdapter.swift MenuAdapter.swift

 | SettingsLogoCell.xib SettingsLogoCell.swift NotificationSettingsDescriptionCell.xib NotificationSettingsDescriptionCell.swift NotificationSettingsCell.xib NotificationSettingsCell.swift PostSettingsDescriptionCell.xib PostSettingsDescriptionCell.swift PostSettingsCell.xib PostSettingsCell.swift MenuLogoCell.xib MenuLogoCell.swift MenuCell.xib MenuCell.swift MenuHeaderView.xib MenuHeaderView.swift


 |

**Groups Module:**

In the menu options we have groups module, clicking on it views a separate newsfeed of groups which include feeds of all the groups related to you. You can react, comment, save, report, delete,go to feed detail and go to group detail as well. Above is the filters for these feeds, seperate view for "MY groups" and "Browse" All this is happening in GroupsController.

My groups has your groups, your joined groups, groups invitations, and your pending invitations. Clicking on any my group will take you to detail of your group, same is for the joined group, for group invitations you can click on join group from here or in groupDetail screen. Pending inviation shows you the pending invitation groups.

Browse will show you suggested groups to which you can join them if they are public or you can request to join if they are private from here or from Group detail screen.

Search is also available for my groups and browse. There is button at the top right which takes user to CreateGroupController, from which you can add name,description, set privacy and add participants before creating group. Create group will takes you back to groupsController.

In GroupDetailsController, you can see group cover, number of participants, group name and description, a button to invite if you are a member or a button join if you are not a member, and if you are in pending state you see Waiting for approval. Below this you have the feeds of groups which are categorised into all, Photos, videos, text, events. There is a separate gallery of group and separated folder of all the documents shared in group. There is button to create post as well, which takes you to generic NewPostController with selected group. You can add you post from here and you will be redirected back to your group after adding a post.

If you are a admin you see an option of manage of clicking three dots button on top right to go to group related settings, and a button to edit group data such as cover image, privacy, name and description. You can also have a leave group option there as well if you are only a member.

Inside manage you have member requests which shows the pending requests to join group, and you have pending posts to be approved. An option to invite members and delete group option as well.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| GroupsController.xib GroupsController.swift GroupDetailsController.xib GroupDetailsController.swift CreateGroupController.xib CreateGroupController.swift EditGroupController.xib EditGroupController.swift ManageGroupController.xib ManageGroupController.swift GroupPickerController.xib GroupPickerController.swift GroupBlockedUsersController.xib GroupBlockedUsersController.swift PendingPostsController.xib PendingPostsController.swift GroupFilterController.xib GroupFilterController.swift GroupMemberRequestsController.xib GroupMemberRequestsController.swift GroupMembersController.xib GroupMembersController.swift
 | GroupsAdapter.swift GroupDetailsAdapter.swift GroupPickerAdapter.swift GroupBlockedUsersAdapter.swift PendingPostsdapter.swift GroupMemberRequestsAdapter.swift GroupMembersAdapter.swift

 | NewGroupCell.xib NewGroupCell.swift GroupCell.xib GroupCell.swift GroupDetailCell.xib GroupDetailCell.swift GroupHeaderImageTableViewCell.xib GroupHeaderImageTableViewCell.swift PPTextWithBgPostCell.xib PPTextWithBgPostCell.swift PPTextPostCell.xib PPTextPostCell.swift PPImagePostCell.xib PPImagePostCell.swift MemberRequestCell.xib MemberRequestCell.swift MembersSentTableViewCell.xib MembersSentTableViewCell.swift

 |

**Favourites Module:**

Favourites is another module inside menu in which we have favourites friends, groups,events and posts. We can search in between them and can go to these modules on clicking the cells.

On clicking favourites, a FavTabBarController opens up which has FavPostsController for posts, FavGroupsController for groups, FavFriendsController for friends, FavEventsController for events.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| FavTabBarController.swift FavFriendsController.xib FavFriendsController.swift FavGroupsController.xib FavGroupsController.swift FavEventsController.xib FavEventsController.swift FavPostsController.xib FavPostsController.swift
 | FavFriendsAdapter.swift FavGroupsAdapter.swift FavPostsAdapter.swift FavEventsAdapter.swift

 | Cells are reused from other modules, no new cells are related to this module.


 |

**Profile Module:**

The profile Module is the feature by which we can see the profile of others and our own profile. We can edit our profile can see our feed, about, experience, Education, certificates, skills, Documents etc. We can see users' events, groups, and media files as well. We can change the profile picture, and add a cover photo.

Clicking on three dots and then edit will take the user to the edit profile screen from which he can add a profile picture and cover under the profile photo tab, set account privacy, edit basic information under the basic info tab, and can also link with social profiles like instagram, facebook, etc.

On viewing someone's profile there is extra two buttons for chat and call. And on three dot click you can add to favorites or can unfriend it.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** | **Others** |
| --- | --- | --- | --- |
| ProfileController.xib ProfileController.swift EditProfileViewController.xib EditProfileViewController.swift EditProfilePhoto.xib EditProfilePhoto.swift ProfileFriendsController.xib ProfileFriendsController.swift SkillController.xib SkillController.swift DocumentController.xib DocumentController.swift DocumentViewerController.xib DocumentViewerController.swift DocumentView.xib DocumentView.swift ExperienceController.xib ExperienceController.swift ExperienceTypeViewController.xib ExperienceTypeViewController.swift ProfessionalProfileController.xib ProfessionalProfileController.swift EditProfileAbout.xib EditProfileAbout.swift CertificateController.xib CertificateController.swift EducationController.xibEducationController.swift | UserProfileAdapter.swift PhotoCollectionAdapter.swift ProfileFriendsAdapter.swift EditProfileAdapter.swift


 | ExperienceTableCell.xib ExperienceTableCell.swift SkillTableCell.xib SkillTableCell.swift EducationTableCell.xib EducationTableCell.swift AboutTableCell.xib AboutTableCell.swift DocumentsTableCell.xib DocumentsTableCell.swift EditSkillTableViewCell.xib EditSkillTableViewCell.swift EditProfileCoverPhotoCell.xib EditProfileCoverPhotoCell.swift ProfileSocialLinks.xib ProfileSocialLinks.swift EditProfileImageCell.xib EditProfileImageCell.swift ProfileAboutHeader.xib ProfileAboutHeader.swift CertificationTableCell.xib CertificationTableCell.swift FriendCell.xib FriendCell.swift FriendsListCell.xib FriendsListCell.swift CreatePostCell.xib CreatePostCell.swift PhotosCollectionTableCell.xib PhotosCollectionTableCell.swift PhotosSegmentTableCell.xib PhotosSegmentTableCell.swift ProfileHeaderInfo.xib ProfileHeaderInfo.swift WorkDetailCell.xib WorkDetailCell.swift ExperienceDetailCell.xib ExperienceDetailCell.swift​​ EmptyTableCell.xib EmptyTableCell.swift ExperienceTypeTableViewCell.xib ExperienceTypeTableViewCell.swift

 | ProfileNetworkHelper.swift GroupsFactory.swift EventsFactory.swift AboutFactory.swift PhotosFactory.swiftPostFactory.swift |

**Friends Module:**

The friends' module contains all the friends-related features combined together. It has friend requests,

Friends list and suggested people. You can sort friends requests to sent and received and can view all as well, you can accept/reject friend requests or you can cancel already sent friend requests from here. In another tab, we have My friends which shows the list of all the friends. You can sort them by cities, universities and company. You can visit profile or can call, send text message. In the suggestions tab, you have list of people you can visit their profiles and then can send friend requests or view profiles as per their privacy

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| FriendsController.xibFriendsController.swift | FriendsAdapter.swiftFriendsTabAdapter.swift | UserCell.xibUserCell.swift |

**Events Module:**

Events is the another important module of the app, from which you can add events, join events and view guest lists, manage etc. When you enter into this module you first see EventsController which has

Public events, my events and friends events. You can apply filters on them to view the needed events, filter by dates. My events has further classification as going events,created events, invited events, and favourite events. Clicking on add button at the top right, you can add your new event. After adding details you can invite friends and then ultimately create the event.

In EventDetailsScreen, you see the details of the events, save an event, view the guest list of the event, which is categorized into going, maybe, and invited. You can search from here as well and you can invite more friends also. You can select your availability for the event as well from here.

You can also update your created event, can mange the event as there are lot of features available in managing the event setting, and you can also delete it.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| EventsController.xib EventsController.swift CreateEventController.xib CreateEventController.swift EventsFilterViewController.xib EventsFilterViewController.swift EventsTimeFilterViewController.xib EventsTimeFilterViewController.swift EventDetailsController.xib EventDetailsController.swift EventGuestListController.xib EventGuestListController.swift EventInviteController.xib EventInviteController.swift ManageEventController.xib ManageEventController.swift EditEventController.xib EditEventController.swift InviteFriendsToEventController.xib InviteFriendsToEventController.swift EventUsersController.xibEventUsersController.swift | EventsAdapter.swift InviteFriendsToEventCollectionViewAdapter.swift InviteFriendsToEventAdapter.swift EventUsersAdapter.swift
 | TwoTabCollectionCell.xib TwoTabCollectionCell.swift EventDashboardHeaderView.xib EventDashboardHeaderView.swift EventCell.xib EventCell.swift EventsSubNavBarCellItem.xib EventsSubNavBarCellItem.swift
 |

**Contact Us Module:**

The app also has the classic contact us module which is used to send queries and problems to help center. You can also add pictures or media files here as well

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| ContactUsController.xib ContactUsController.swift
 | ContactUsAdapter.swift
 | N/A |

**Auth and startup Module:**

This module includes the registration screens, login screens and password related screens. Email, birth info, educational info, password etc are the sub screens of registration module.

Startup module has the startup related screens like onboarding and Welcome screens.

**Classes level explanation:**

| **Controllers** | **Adapters** | **Cells** |
| --- | --- | --- |
| AddEmailController.xib AddEmailController.swift VerifyEmailController.xib VerifyEmailController.swift SelectUniversityController.xib SelectUniversityController.swift AddNameController.xib AddNameController.swift SetPasswordController.xib SetPasswordController.swift SelectPhotoController.xib SelectPhotoController.swift InviteFriendsController.xib InviteFriendsController.swift EducationalInfoController.xib EducationalInfoController.swift VerifyEmailController.xib VerifyEmailController.swift BirthInfoController.xib BirthInfoController.swift LoginController.xib LoginController.swift NewPasswordController.xib NewPasswordController.swift ForgotPasswordController.xib ForgotPasswordController.swift VerifyCodeController.xib VerifyCodeController.swift OnboardingController.xib OnboardingController.swift WelcomeController.xibWelcomeController.swfft | N/A
 | N/A |

**Common folder and supporting files:**

Common folder contains all the classes that we use for different generic tasks needed in the app. Same is the case with supporting files it contains all the supporting files such as CallManage, ImageManager, BorderedTextField etc.


