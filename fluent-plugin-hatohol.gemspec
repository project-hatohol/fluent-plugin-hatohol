# -*- mode: ruby; coding: utf-8 -*-
#
# Copyright (C) 2014 Project Hatohol
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

Gem::Specification.new do |spec|
  spec.name = "fluent-plugin-hatohol"
  spec.version = "1.0.0"
  spec.authors = ["Project Hatohol"]
  spec.email = []
  spec.summary = "A Fluentd plugin to send events to Hatohol"
  spec.description = "You can integrated log monitoring system with Hatohol"
  spec.homepage = "https://github.com/project-hatohol/fluent-plugin-hatohol"
  spec.license = "LGPLv2.1 or later"

  spec.files = ["README.md", "Gemfile", "#{spec.name}.gemspec"]
  spec.files += [".yardopts"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("sample/**/*")
  spec.files += Dir.glob("doc/text/**/*")
  spec.test_files += Dir.glob("test/**/*")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("fluentd")
  spec.add_runtime_dependency("bunny")

  spec.add_development_dependency("rake")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("packnga")
  spec.add_development_dependency("kramdown")
end
