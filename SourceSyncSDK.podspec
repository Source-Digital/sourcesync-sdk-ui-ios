Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.13"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers integrate Source Digital's platform features into their iOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  # Define supported platforms (iOS only now)
  spec.ios.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", 
                        :tag => "#{spec.version}" }
  
  # Verify these paths match your actual project structure
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  # Explicitly exclude Package.swift
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  # DivKit dependencies
  spec.dependency "DivKit", "~> 31.14.0"
  spec.dependency "DivKitExtensions", "~> 31.14.0"
  
  # 🚀 FIXED: Universal Architecture Support
  spec.pod_target_xcconfig = { 
    # Support both Intel and Apple Silicon simulators + devices
    'ARCHS' => 'arm64 x86_64',
    'VALID_ARCHS' => 'arm64 x86_64',
    
    # Don't exclude any architectures - let Xcode decide based on build target
    # 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '', # Removed exclusions
    
    # Enable building for inactive architectures (universal binary support)
    'ONLY_ACTIVE_ARCH' => 'NO',
    
    # Ensure proper iOS simulator support
    'SUPPORTS_MACCATALYST' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    
    # Swift compilation settings
    'SWIFT_VERSION' => '5.7',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    
    # Build settings for better compatibility
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited)',
    'OTHER_LDFLAGS' => '$(inherited)',
    'OTHER_SWIFT_FLAGS' => '$(inherited)',
    
    # Deployment target consistency
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0'
  }
  
  # 🚀 FIXED: Consumer app configuration - no architecture restrictions
  spec.user_target_xcconfig = {
    # Allow consumer apps to build for any architecture they need
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64',
    # Don't force exclusions on consumer apps
    # 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '' # Removed
  }
  
  # iOS framework
  spec.ios.framework = "UIKit"
  spec.swift_version = "5.7"
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
  
  # 🆕 Additional configuration for DivKit compatibility
  spec.ios.pod_target_xcconfig = {
    'ONLY_ACTIVE_ARCH' => 'NO',
    'ARCHS' => 'arm64 x86_64',
    'VALID_ARCHS' => 'arm64 x86_64',
    
    # Ensure DivKit dependencies build correctly
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
    'HEADER_SEARCH_PATHS' => '$(inherited)',
    'LIBRARY_SEARCH_PATHS' => '$(inherited)',
    
    # Swift/ObjC interop settings for DivKit
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES'
  }
end