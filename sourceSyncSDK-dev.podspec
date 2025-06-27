Pod::Spec.new do |spec|
  spec.name          = 'SourceSyncSDK'
  spec.version       = '1.0.1-dev'
  spec.summary       = 'UI SDK for local development'
  spec.homepage      = 'https://github.com/yourorg/ui-sdk'
  spec.license       = { :type => 'MIT' }
  spec.author        = { 'Ayman Badawy' => 'test@example.com' }
  spec.source        = { :path => 'SourceSyncSDK/' }
  
  spec.ios.deployment_target = '14.0'
  spec.swift_version = '5.7'
  
  # XCFramework
  spec.vendored_frameworks = 'SourceSyncSDK/build/XCFrameworks/release/SourceSyncSDK.xcframework'
  
  # Dependencies
  spec.dependency 'React-Core'
  
  # Universal binary support
  spec.pod_target_xcconfig = {
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64 arm64e',
    'EXCLUDED_ARCHS' => '',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
  
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS' => '',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)'
  }
  
  spec.requires_arc = true
end