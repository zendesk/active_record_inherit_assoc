name = "active_record_inherit_assoc"

Gem::Specification.new name, "2.6.0" do |s|
  s.summary = "Attribute inheritance for AR associations"
  s.authors = ["Ben Osheroff"]
  s.email = ["ben@gimbo.net"]
  s.files = `git ls-files lib`.split("\n")
  s.license = "Apache License Version 2.0"
  s.homepage = "https://github.com/zendesk/#{name}"

  s.add_runtime_dependency "activerecord", ">= 3.2.0", "< 5.3"

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-rg'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'wwtd'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
end
