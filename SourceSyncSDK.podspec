Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.2.1"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers                  integrate Source Digital's platform features into their iOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "13.0"
  spec.tvos.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", :tag => "#{spec.version}" }
  
  # Verify these paths match your actual project structure
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"

  # Explicitly exclude Package.swift
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  
  spec.swift_version = "5.7"
  spec.requires_arc = true
  
end
