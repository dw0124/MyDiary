# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MyDiary' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MyDiary
  pod 'NMapsMap'
  pod 'SnapKit'
  pod 'Alamofire'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseDatabase'
  pod 'FirebaseStorage'
  pod 'DropDown'
  pod 'GoogleSignIn'
  pod 'KakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoSDKAuth'  # 사용자 인증
  pod 'KakaoSDKUser'  # 카카오 로그인, 사용자 관리
  inhibit_all_warnings!
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
end