require_relative "lib/active_record_inherit_assoc/version"

name = "active_record_inherit_assoc"

Gem::Specification.new name, ActiveRecordInheritAssoc::VERSION do |s|
  s.summary = "Attribute inheritance for AR associations"
  s.authors = ["Ben Osheroff"]
  s.email = ["ben@gimbo.net"]
  s.files = `git ls-files lib`.split("\n")
  s.license = "Apache License Version 2.0"
  s.homepage = "https://github.com/zendesk/#{name}"

  s.add_runtime_dependency 'activerecord', '>= 6.1'
  s.required_ruby_version = '>= 3.1'
end
