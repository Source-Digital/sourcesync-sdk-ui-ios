Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.14"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers integrate Source Digital's platform features into their iOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "13.0"
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", :tag => "#{spec.version}" }
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  spec.dependency "DivKit", "~> 31.14.0"
  spec.dependency "DivKitExtensions", "~> 31.14.0"
  
  # 🚀 SINGLE, COMPREHENSIVE CONFIGURATION (Fixed duplicate issue)
  spec.pod_target_xcconfig = { 
    'ARCHS' => 'arm64 x86_64',
    'VALID_ARCHS' => 'arm64 x86_64',
    'ONLY_ACTIVE_ARCH' => 'NO',
    'SUPPORTS_MACCATALYST' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_VERSION' => '5.7',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
    'HEADER_SEARCH_PATHS' => '$(inherited)',
    'LIBRARY_SEARCH_PATHS' => '$(inherited)',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited)',
    'OTHER_LDFLAGS' => '$(inherited)',
    'OTHER_SWIFT_FLAGS' => '$(inherited)'
  }
  
  spec.user_target_xcconfig = {
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64'
  }
  
  spec.ios.framework = "UIKit", "Foundation"
  spec.swift_version = "5.7"
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
end