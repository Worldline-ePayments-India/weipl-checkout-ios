#
# Be sure to run `pod lib lint weipl_checkout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'weipl_checkout'
  s.version          = '1.1.1'
  s.summary          = 'iOS Checkout SDK for Worldline ePayments India.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This is official native SDK to integrate Worldline ePayments India Checkout.
                       DESC

  s.homepage         = 'https://github.com/Worldline-ePayments-India/weipl-checkout-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weipl-checkout-ios' => 'ashish.palaskar@worldline.com' }
  s.source           = { :git => 'https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = '4.2'
  s.source_files = 'weipl_checkout/Classes/**/*'

  # s.resource_bundles = {
  #   'weipl_checkout' => ['weipl_checkout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
