# Uncomment the next line to define a global platform for your project
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
 platform :ios, '13.0'


target 'NerveLive' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Amplify', '1.19.2'
  pod 'Amplify/Tools'
  pod 'AmplifyPlugins/AWSS3StoragePlugin'
  pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
  pod 'AmplifyPlugins/AWSAPIPlugin'
  pod 'AmplifyPlugins/AWSPinpointAnalyticsPlugin'
  pod 'AWSPinpoint'
  pod 'AWSMobileClient'
#  pod 'AWSAppSync'

  # 直播
  pod 'AWSCognitoIdentityProvider'
  pod 'CommonCryptoModule'
  pod 'AWSKinesisVideo'
  pod 'AWSKinesisVideoSignaling'
  pod 'GoogleWebRTC', '~> 1.1'
  pod 'Starscream', '~> 3.1.1'

  pod 'YYText', '~> 1.0.7' # YY
  pod 'IQKeyboardManagerSwift', '~> 6.5.12'
  pod 'Kingfisher', '~> 7.9.1' # Image loading library
  pod 'SVProgressHUD', '~> 2.2.5' # HUD loading
  # Pods for NerveLive

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings["ONLY_ACTIVE_ARCH"] = "NO"
        end
    end
    installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = $iOSVersion
    end
end
