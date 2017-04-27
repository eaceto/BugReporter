#
# Be sure to run `pod lib lint BugReporter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BugReporter'
  s.version          = '0.1.0'
  s.summary          = 'A simple and elegant bug reporting tool for you apps.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Bug Reporter is a tool that simplifies the process of reporting bugs and comments from users to developers. 
			  DESC

  s.homepage         = 'https://github.com/eaceto/BugReporter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kimi' => 'kimi@wolfram.io' }
  s.source           = { :git => 'https://github.com/eaceto/BugReporter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/eaceto'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BugReporter/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'MessageUI','Photos'
  s.dependency 'SwiftyJSON', '~> 3.1'
end
