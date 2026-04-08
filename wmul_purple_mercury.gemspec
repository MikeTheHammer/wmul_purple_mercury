Gem::Specification.new do |s|
  s.name                    = "wmul_purple_mercury"
  s.version                 = "0.0.11"
  s.authors                 = ["Mike Stanley"]
  s.description             = "The build engine for WMUL-FM's Operations Manuals."
  s.email                   = "stanley50@marshall.edu"
  s.files                   = ["lib/wmul_purple_mercury/cli.rb", "lib/wmul_purple_mercury.rb"]
  s.test_files              = ["test/test_filename_manager.rb"]
  s.homepage                = "https://github.com/MikeTheHammer/wmul_purple_mercury"
  s.require_paths           = ["lib"]
  s.rubygems_version        = "3.4.19"
  s.summary                 = "The build engine for WMUL-FM's Operations Manuals."
  s.license                 = "MIT"
  s.required_ruby_version   = ">=3.2.3"
  s.executables             << "purple_mercury"
  s.add_runtime_dependency("asciidoctor", "~> 2.0", ">= 2.0.26")
  s.add_runtime_dependency("asciidoctor-epub3", "~> 2.3", ">= 2.3.0")
  s.add_runtime_dependency("asciidoctor-pdf", "~> 2.3", ">= 2.3.24")
  s.add_runtime_dependency("asciidoctor-reducer", "~> 1.1", ">= 1.1.2") 
  s.add_runtime_dependency("semantic_logger", "~> 4.17", ">= 4.17.0") 
  s.add_runtime_dependency("dry-cli", "~> 1.1")
end
