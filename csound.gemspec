Gem::Specification.new do |s|
	s.name		= 'csound'
	s.version	= '0.0.5'
	s.date		= '2023-07-30'
	s.summary	= 'Csound Gem for Ruby'
	s.description	= 'Csound for Ruby, through FFI'
	s.authors	= ["Johann Philippe"]
	s.email		= 'johannphilippe@lilo.org'
	s.files		= ["lib/csound.rb"]
	s.homepage	= 'https://rubygems.org/gems/csound'
	s.license	= 'LGPL-2.1'

	s.add_runtime_dependency 'bundler', '~> 2.1'
	s.add_runtime_dependency 'ffi', '~> 1.11'
    s.add_runtime_dependency 'os', '~> 1.1', '>= 1.1.4'
	s.metadata['allowed_push_host'] = 'https://rubygems.org'
end