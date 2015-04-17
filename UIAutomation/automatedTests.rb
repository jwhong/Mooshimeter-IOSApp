#!/usr/bin/env ruby
require 'bundler/setup'
require 'illuminator'

thisPath = File.expand_path(File.dirname(__FILE__))
buildArtifactsDir = "#{thisPath}/../buildArtifacts"

allTestPath = "#{thisPath}/AllTests.js"

# Hard-coded options

options = Illuminator::Options.new
options.buildArtifactsDir = buildArtifactsDir
options.xcode.appName = 'Mooshimeter'
options.xcode.scheme = 'Mooshimeter'
options.xcode.projectDir = "#{thisPath}/.."


options.illuminator.entryPoint = 'runTestsByTag'
options.illuminator.test.tags.any = ['nohardware']
options.illuminator.clean.xcode = true
options.illuminator.clean.artifacts = true
options.illuminator.clean.noDelay = true
options.illuminator.task.build = true
options.illuminator.task.automate = true
options.illuminator.task.setSim = true
options.simulator.device = 'iPhone 5'
options.simulator.version = '7.1'
options.simulator.language = 'en'
options.simulator.killAfter = true

options.instruments.doVerbose = true
options.instruments.timeout = 30

options.javascript.testPath = allTestPath
options.javascript.implementation = 'iphone'

success = Illuminator::runWithOptions options

exit 1 unless success
