# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'motion-cocoapods'
require "rubygems"
require 'bundler'
Bundler.require
#ENV['ARR_CYCLES_DISABLE'] ='1'
Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.frameworks << 'CoreLocation'
  app.files_dependencies "app/lib/iphone/ext/string.rb" => ["app/app_delegate.rb"]
  app.pods do
    pod 'MMDrawerController'
    pod "RaptureXML", :git => "https://github.com/IvanRublev/RaptureXML.git"
  end

  app.info_plist['UIStatusBarHidden'] = true

  app.name = 'Busme'
  app.identifier = "com.adiron.busme"
  app.codesign_certificate = "iOS Development: Polar Humenn (V3VBML9S5C)"
  app.provisioning_profile = "/Users/Polar/src/Apple/Provisioning/NickLarissaGriff.mobileprovision"
  app.deployment_target = "7.0"

end

#puts "Doing Motion Builder Setup"
#MotionBundler.setup
#puts "#{JSON.methods}"
