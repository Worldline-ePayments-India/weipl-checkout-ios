
Pod::Spec.new do |s|
  s.name             = 'weipl_checkout'
  s.version          = '1.3.2'
  s.summary          = 'iOS Checkout SDK for Worldline ePayments India.'
  s.description      = <<-DESC
  This is official native SDK to integrate Worldline ePayments India Checkout.
                       DESC

  s.homepage         = 'https://github.com/Worldline-ePayments-India/weipl-checkout-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weipl-checkout-ios' => 'ashish.palaskar@worldline.com' }
  s.source           = { :git => 'https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.requires_arc = true
  s.ios.resource_bundle = { 'weipl_checkout' => 'Sources/**/*.{lproj,swiftmodules,png,json}' }
  s.swift_version = '4.2'
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.exclude_files = 'Sources/weipl_checkout.xcframework/*.plist'
  s.vendored_frameworks = 'Sources/weipl_checkout.xcframework'

end