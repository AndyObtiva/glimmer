Copyright (c) 2011 Annas Al Maleh.
All rights reserved. This program and the accompanying materials
are made available under the terms of the Eclipse Public License v1.0
which accompanies this distribution, and is available at
http://www.eclipse.org/legal/epl-v10.html

Contributors:
* Annas Al Maleh - initial API and implementation
* Dennis Theisen

== Glimmer

![Glimmer](https://github.com/AndyObtiva/glimmer/raw/master/images/Bitter-sweet.jpg)

Glimmer is a JRuby DSL that enables easy and efficient authoring of desktop application user-interfaces. It relies on the robust platform-independent Eclipse SWT library. Glimmer comes with built-in data-binding support to greatly facilitate synchronizing UI with domain models.
 
== Example

  shell {
    text "Example"
    label {
      text "Hello World!"
    }
  }.open

== Getting Started
1. Download the "SWT binary and source" archive from the Eclipse site and follow their instructions.
   http://www.eclipse.org/swt/
2. Download and setup jRuby 1.5.6 (rvm install jruby -v1.5.6)
3. Install bundler (gem install bundler)
4. Install project required gems (bundle install)
5. Write a program that requires the file "lib/swt.rb" and has the UI class (view) include the Glimmer module
6. Run your program with jruby

== Samples

Check the "samples" folder for examples on how to write Glimmer applications.

== Mac Support

In order to run Glimmer on the Mac, you need to pass an extra option to JRuby. For example:
jruby samples/hello_world.rb -XstartOnFirstThread

== Background

Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

== Resources
* {Eclipse Zone Tutorial}[http://eclipse.dzone.com/articles/an-introduction-glimmer]
* {InfoQ Article}[http://www.infoq.com/news/2008/02/glimmer-jruby-swt]
* {RubyConf 2008 Video}[http://rubyconf2008.confreaks.com/desktop-development-with-glimmer.html]
* {Code Painter Blog}[http://andymaleh.blogspot.com/search/label/Glimmer]