Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.15"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers integrate Source Digital's platform features into their iOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "13.0"
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", :tag => "#{spec.version}" }
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  spec.dependency "DivKit", "~> 32.1.0"
  spec.dependency "DivKitExtensions", "~> 32.1.0"
  
  # 🚀 COMPREHENSIVE ARCHITECTURE CONFIGURATION
  spec.pod_target_xcconfig = { 
    # Architecture settings - KEY FIX for simulator issues
    'ARCHS' => 'arm64 x86_64',
    'VALID_ARCHS' => 'arm64 x86_64',
    'ONLY_ACTIVE_ARCH' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '',  # KEY: Don't exclude any archs for simulator
    
    # Swift and Module settings
    'SWIFT_VERSION' => '5.7',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',  # KEY: Enable module stability
    'ENABLE_LIBRARY_EVOLUTION' => 'YES',        # KEY: Swift ABI stability
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    
    # Deployment and compatibility
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0',
    'SUPPORTS_MACCATALYST' => 'NO',
    'ENABLE_BITCODE' => 'NO',
    
    # Search paths
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
    'HEADER_SEARCH_PATHS' => '$(inherited)',
    'LIBRARY_SEARCH_PATHS' => '$(inherited)',
    
    # Compiler settings
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SWIFT_PACKAGE=1',
    'OTHER_LDFLAGS' => '$(inherited)',
    'OTHER_SWIFT_FLAGS' => '$(inherited) -enable-library-evolution',
    
    # Linker settings for better compatibility
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks @loader_path/Frameworks',
    'INSTALL_PATH' => '$(LOCAL_LIBRARY_DIR)/Frameworks',
    'SKIP_INSTALL' => 'YES',
    
    # Debug settings
    'DEBUG_INFORMATION_FORMAT' => 'dwarf-with-dsym',
    'COPY_PHASE_STRIP' => 'NO',
    'STRIP_INSTALLED_PRODUCT' => 'NO'
  }
  
  # User target configuration - what gets applied to the consuming app
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '',  # KEY: Don't exclude simulator archs
    'VALID_ARCHS' => 'arm64 x86_64',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks'
  }
  
  # Framework dependencies
  spec.frameworks = "UIKit", "Foundation"
  spec.swift_version = "5.7"
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
  
  # Compiler flags
  spec.compiler_flags = '-DSWIFT_PACKAGE=1'
  
  # Weak frameworks (if needed)
  # spec.weak_frameworks = "SomeOptionalFramework"
  
  # Static framework configuration (uncomment if needed)
  # spec.static_framework = true
end