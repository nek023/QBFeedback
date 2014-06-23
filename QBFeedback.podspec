Pod::Spec.new do |s|
  s.name         = "QBFeedback"
  s.version      = "1.0.0"
  s.summary      = "QBFeedback is the library for getting feedbacks from the users easily."
  s.homepage     = "http://github.com/questbeat/QBFeedback"
  s.license      = 'MIT'
  s.author       = { "questbeat" => "questbeat@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "git@github.com:questbeat/QBFeedback.git", :tag => "1.0.0" }
  s.source_files = 'QBFeedback', 'QBFeedback/**/*.{h,m}'
  s.resources    = "QBFeedback/Resources/*.lproj"
  s.requires_arc = true
end

