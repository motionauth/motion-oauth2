# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")

# Use `rake` to start the iOS app or
# `rake osx=true` to start the OS X app.
if ENV["osx"]
  require "motion/project/template/osx"
else
  require "motion/project/template/ios"
end
require "./lib/oauth2"

begin
  require "bundler"
  require "motion/project/template/gem/gem_tasks"
  Bundler.require
rescue LoadError
end

# Load the gems used for development
require "guard/motion"
require "motion_print"
require "motion-redgreen"
require "RackMotion"
require "webstub"

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = "motionauth-oauth2"
end
