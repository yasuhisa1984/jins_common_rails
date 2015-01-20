$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jins_common_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jins_common_rails"
  s.version     = JinsCommonRails::VERSION
  s.authors     = ["Muneyasu Wada"]
  s.email       = ["mtahiti80@jins-partners.com"]
  s.homepage    = "http:www.jins-partners.com"
  s.summary     = "Summary of JinsCommonRails."
  s.description = " Description of JinsCommonRails."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.11"
  s.add_dependency "settingslogic"
  s.add_dependency "happymapper"
  s.add_dependency "aws-sdk"
  s.add_dependency "peddler"
  s.add_dependency "amazon-ecs"
  s.add_dependency "google-api-client"
  s.add_dependency "cloudprint"

  # s.add_development_dependency "sqlite3"
end
