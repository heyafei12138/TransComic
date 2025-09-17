# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'comic' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

   # Pods for Translat
  pod 'Alamofire'      # 网络请求
  pod 'SnapKit'        # 约束布局
#  pod 'Kingfisher'     # 图片加载
#  pod 'SwiftyJSON'     # JSON解析
  pod 'SwiftyUserDefaults'
  pod 'SwiftyStoreKit'
  pod 'Toast-Swift'

  pod 'lottie-ios'
  pod 'Localize-Swift', '~> 3.2'
  pod 'SwiftyUserDefaults'
  pod 'SwiftyStoreKit'
  pod 'JKSwiftExtension'
  pod 'SwiftMessages'
  pod 'MBProgressHUD', :git => 'https://github.com/jdg/MBProgressHUD.git', :branch => 'master'
#  pod 'Bugly', '~> 2.6.1'

end

target 'TransComic' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TransComic

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Bugly'
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'

      end
    end
  end
end


