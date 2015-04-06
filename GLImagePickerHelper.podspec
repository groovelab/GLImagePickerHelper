Pod::Spec.new do |s|
  s.name         = "GLImagePickerHelper"
  s.version      = "0.0.2"
  s.summary      = "GLImagePickerHelper, Customise yourself."
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Takeo Namba" => "nanba@groovelab.asia" }
  s.social_media_url = "http://groovelab.asia/blog"
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/groovelab/GLImagePickerHelper.git", :tag => "0.0.2" }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true
end
