Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-filter-cef"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Trevin Teacutter"]
  spec.email         = ["tjteacutter1@cougars.ccis.edu"]
  spec.description   = %q{common event format(CEF) filter plugin for fluentd}
  spec.summary       = %q{common event format(CEF) filter plugin for fluentd}
  spec.homepage      = "https://github.com/trevinteacutter/fluent-plugin-filter-cef"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", ">= 0.14.20", "< 2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "test-unit"
end
