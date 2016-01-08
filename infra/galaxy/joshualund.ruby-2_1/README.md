ruby-2.1
========

Ansible role that compiles and installs Ruby 2.1 (https://www.ruby-lang.org) and Bundler (http://bundler.io).

Role Variables
--------------

**Variables that are set by the role itself (and that shouldn't need to be modified)**

The defaults will install the latest release of Ruby 2.1.

> ruby_library_version: Other roles may use this to determine where gems are located.

> ruby_version: This variable controls the version of Ruby that will be compiled and installed. It should correspond with the tarball filename excluding the ".tar.gz" extension (e.g. "ruby-2.1.0").

> ruby_checksum: The SHA256 checksum of the gzipped tarball that will be downloaded and compiled.

> ruby_download_location: The URL that the tarball should be retrieved from. Using the ruby_version variable within this variable is a good practice (e.g. "http://cache.ruby-lang.org/pub/ruby/2.1/{{ ruby_version }}.tar.gz").

> ruby_bundler_flags: This variable controls any extra flags that you would like to be passed to RubyGems when Bundler is first installed. For example, you can set this to "--no-document" to disable documentation generation, or "--version VERSION" to install a particular version of Bundler. The default value is "--no-document".

Dependencies
------------

* ruby-common
  * [Galaxy](https://galaxy.ansibleworks.com/list#/roles/143)
  * [GitHub](https://github.com/jlund/ansible-ruby-common)

The variables in this role will be used by the ruby-common role to install the correct version.

License
-------

The MIT License (MIT)

Copyright (c) 2013 Joshua Lund

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author Information
------------------

You can find me on [Twitter](https://twitter.com/joshualund), and on [GitHub](https://github.com/jlund/). I also occasionally blog at [MissingM](http://missingm.co).
