Pod::Spec.new do |s|
  s.name = 'OMGradientLayer'
  s.version = '0.1.0'
  s.license = 'APACHE 2.0'
  s.summary = 'Shading gradient layer with animatable properties in Swift'
  s.homepage = 'https://github.com/jaouahbi/OMGradientLayer'
  s.social_media_url = 'http://twitter.com/JorgeOuahbi'
  s.authors = { 'Jorge Ouahbi' => 'jorgeouahbi@gmail.com' }
  s.source = { :git => 'https://github.com/jaouahbi/OMGradientLayer.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.platform      = :ios, '8.0'

  s.source_files = 'OMGradientLayer/*.swift'

  s.requires_arc = true
end