name = "active_record_inherit_assoc"

Gem::Specification.new name, "2.13.2" do |s|
  s.summary = "Attribute inheritance for AR associations"
  s.authors = ["Ben Osheroff"]
  s.email = ["ben@gimbo.net"]
  s.files = `git ls-files lib`.split("\n")
  s.license = "Apache License Version 2.0"
  s.homepage = "https://github.com/zendesk/#{name}"

  s.add_runtime_dependency 'activerecord', '>= 5.0.0', '< 7.2'
  s.required_ruby_version = '>= 2.6'
end
