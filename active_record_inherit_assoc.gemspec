$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "active_record_inherit_assoc"

Gem::Specification.new name, "2.0.0" do |s|
  s.summary = "Attribute inheritance for AR associations"
  s.authors = ["Ben Osheroff"]
  s.email = ["ben@gimbo.net"]
  s.files = `git ls-files`.split("\n")
  s.license = "Apache License Version 2.0"
  s.homepage = "http://github.com/zendesk/#{name}"
  s.add_runtime_dependency "activerecord", ">=3.2.0", "< 5"
end

