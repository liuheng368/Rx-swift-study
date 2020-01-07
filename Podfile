# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'


target 'RxSwift-test' do

  use_frameworks!
     pod 'RxSwift'
     pod 'RxCocoa'
     pod 'RxDataSources'
     pod 'RxAlamofire'
     pod 'MLeaksFinder'
     pod 'CleanJSON'
     pod 'Alamofire'
     pod 'Moya'
     pod 'MJRefresh'
pod 'DDSwiftNetwork', :git => 'git@git.corp.imdada.cn:ios/DDSwiftNetwork.git'
#pod 'Moya/RxSwift','~>13.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end

