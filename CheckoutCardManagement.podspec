Pod::Spec.new do |s|
    s.name         = "CheckoutCardManagement"
    s.version      = "2.1.0"
    s.summary      = "Checkout Card Management"
    s.description  = <<-DESC
    Checkout Card Management
    This library contains cards management for Checkout iOS SDKs
                     DESC
    s.homepage     = "https://github.com/checkout/CheckoutCardManagement-iOS"
    s.swift_version = "5.7"
    s.license      = "MIT"
    s.author       = { "Checkout.com Integration" => "integration@checkout.com" }
    s.platform     = :ios, "11.0"
    s.source       = { :git => "https://github.com/checkout/CheckoutCardManagement-iOS.git", :tag => "#{s.version}" }
  
    s.vendored_frameworks = [
      # Main framework
      "CheckoutCardManagement.xcframework",
      
      # Internal  dependencies in their dedicated folder
      "SupportFrameworks/CheckoutCardNetwork.xcframework",
      "SupportFrameworks/SecureLogAPI.xcframework"
    ]

    # External dependencies
    s.dependency "CheckoutEventLoggerKit"
  end
