
Pod::Spec.new do |s|
s.name         = "DSHListView"
s.version      = "0.0.1"
s.summary      = "提供滚动视图嵌套滚动视图的一种布局方式"
s.description  = <<-DESC
    提供滚动视图嵌套滚动视图的一种布局方式，解决手势冲突，划分视图区域。
                DESC
s.homepage     = "https://github.com/568071718/ListView"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "lu" => "568071718@qq.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/568071718/ListView.git", :tag => s.version }
s.requires_arc = true
s.source_files = 'Classes'
end
