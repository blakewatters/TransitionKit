require 'rubygems'
require 'bundler'
Bundler.setup
require 'xctasks/test_task'

XCTasks::TestTask.new(:spec) do |t|
  t.workspace = 'TransitionKit.xcworkspace'
  t.schemes_dir = 'Specs/Schemes'
  t.runner = :xcpretty
  t.actions = %w{clean test}
  
  t.subtask(ios: 'iOS Specs') do |s|
    s.sdk = :iphonesimulator
  end
  
  t.subtask(osx: 'OS X Specs') do |s|
    s.sdk = :macosx
  end
end

task :default => 'spec'
