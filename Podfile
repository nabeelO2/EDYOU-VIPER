# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'



target 'EDYOU' do
#  pod 'HXPHPicker'
  use_frameworks!
  pod 'R.swift'
#  pod 'SwiftLint'
  pod 'IQKeyboardManagerSwift', '6.5.0'
#  pod 'SwifterSwift'
  pod 'KeychainSwift'
  pod 'SDWebImage'
  pod 'TransitionButton'
  pod 'SkeletonView', '~> 1.29.2'
  pod 'ActiveLabel'
  pod 'SwiftMessages'
  #pod 'KDCircularProgress'
  pod 'DPTagTextView', :git => 'https://github.com/applebyte1992/DPTagTextView.git'
  pod 'EmptyDataSet-Swift', '~> 5.0.0'
  pod 'GoogleMaps'
  pod 'EZCustomNavigation'
  pod 'ImageSlideshow', '~> 1.9.2'
  pod 'Bugsnag', '~> 6.21.0'
  pod 'FSCalendar'
#  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  pod 'JWTDecode', '~> 2.3'
  pod 'TagListView'
  pod 'RealmSwift'
  pod 'PanModal'
  pod "SwiftyXMLParser"
  pod 'appendAttributedString'
  pod 'GPVideoPlayer'
  pod 'UXCam'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod "PryntTrimmerView"
  pod 'SteviaLayout'
  pod 'lottie-ios'
  pod 'SwiftyJSON', '~> 4.0'

#  pod 'HXPHPicker'
#  pod 'YPImagePicker'
#  pod 'VersaPlayer'
#  pod 'Bugsnag'


  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
              config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
           end
      end
    end
  end
  
end
 
