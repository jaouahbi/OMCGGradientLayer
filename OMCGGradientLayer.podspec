#
# Be sure to run `pod lib lint OMShadingGradientLayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OMCGGradientLayer'
  s.version          = '0.1.0'
  s.summary          = 'CoreGraphics gradient CALayer with animatable properties.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description     = 'CoreGraphics gradient CALayer with animatable properties in Swift.'

  s.homepage         = 'https://github.com/jaouahbi/OMCGGradientLayer'
  s.screenshots      = 'https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/8873/ScreenShot.png'
  s.license          = { :type => 'APACHE 2.0', :file => 'LICENSE' }
  s.author           = { 'Jorge Ouahbi' => 'jorgeouahbi@gmail.com' }
  s.source           = { :git => 'https://github.com/jaouahbi/OMCGGradientLayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/a_c_r_a_t_a'
  s.ios.deployment_target = '8.0'
  s.source_files = 'OMCGGradientLayer/Classes/**/*'
end