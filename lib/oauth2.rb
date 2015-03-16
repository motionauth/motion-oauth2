# encoding: utf-8
require "motion-cocoapods"
require "motion-support/core_ext/hash"

unless defined?(Motion::Project::Config)
  fail "This file must be required within a RubyMotion project Rakefile."
end

lib_dir_path = File.dirname(File.expand_path(__FILE__))
Motion::Project::App.setup do |app|
  # Load shared files
  app.files.unshift(Dir.glob(File.join(lib_dir_path, "oauth2/**/*.rb")))

  # Load files shared by Cocoa platforms
  case app.template
  when :ios, :osx
    app.files.unshift(Dir.glob(File.join(lib_dir_path, "oauth2-cocoa/**/*.rb")))
  end

  app.pods do
    pod "CocoaSecurity", "~> 1.2"
  end
end
