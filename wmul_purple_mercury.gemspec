Gem::Specification.new do |s|
  s.name                    = "wmul_purple_mercury"
  s.version                 = "0.0.2"
  s.authors                 = ["Mike Stanley"]
  s.description             = "The build engine for WMUL-FM's Operations Manuals."
  s.email                   = "stanley50@marshall.edu"
  s.files                   = ["lib/wmul_purple_mercury/cli.rb", "lib/wmul_purple_mercury.rb"]
  s.test_files              = ["test/test_filename_manager.rb"]
  s.homepage                = "https://github.com/MikeTheHammer/wmul_purple_mercury"
  s.require_paths           = ["lib"]
  s.rubygems_version        = "3.6.9"
  s.summary                 = "The build engine for WMUL-FM's Operations Manuals."
  s.license                 = "MIT"
  s.required_ruby_version   = "3.4.9"
  s.executables             << "purple_mercury"
  s.add_runtime_dependency("asciidoctor", "~> 2.0", ">= 2.0.26")
  s.add_runtime_dependency("asciidoctor-reducer", "~> 1.1", ">= 1.1.2") 
  s.add_runtime_dependency("dry-cli", "~> 1.1")
end
