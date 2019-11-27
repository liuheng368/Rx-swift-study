# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

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
#pod 'Moya/RxSwift','~>13.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['DYLIB_COMPATIBILITY_VERSION'] = ''
    end
  end
end