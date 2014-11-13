# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'motion-cocoapods'
require "rubygems"
require 'bundler'
#require "motion-yaml"
#require "motion-bundler"
#require "json/pure"
Bundler.require
ENV['ARR_CYCLES_DISABLE'] ='1'
Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'promotion-motion-kit'
  app.frameworks << 'CoreLocation'
  app.files_dependencies "app/lib/string.rb" => ["app/app_delegate.rb"]
  app.pods do
    pod 'MMDrawerController'
    pod "RaptureXML", :git => "https://github.com/IvanRublev/RaptureXML.git"
  end
end

#puts "Doing Motion Builder Setup"
#MotionBundler.setup
#puts "#{JSON.methods}"
