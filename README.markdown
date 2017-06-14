Glimmer (The Original One And Only)
===
Glimmer is a cross-platform Ruby desktop development library. Glimmer's main innovation is a JRuby DSL that enables easy and efficient authoring of desktop application user-interfaces while relying on the robust platform-independent Eclipse SWT library. Glimmer additionally innovates by having built-in desktop UI data-binding support to greatly facilitate synchronizing the UI with domain models. As a result, that achieves true decoupling of object oriented components, enabling developers to solve business problems without worrying about UI concerns, or alternatively drive development UI-first, and then write clean business components test-first afterward.

You may learn more by reading this article: * [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)

![Glimmer](https://github.com/AndyObtiva/glimmer/raw/master/images/Bitter-sweet.jpg)

Example
---
    shell {
      text "Example"
      label {
        text "Hello World!"
      }
    }.open

Getting Started
---
1. Download the "SWT binary and source" archive from the Eclipse site and follow their instructions.
   [http://www.eclipse.org/swt/](http://www.eclipse.org/swt/) ( e.g. http://download.eclipse.org/eclipse/downloads/drops4/R-4.6.3-201703010400/#SWT )
2. Add swt.jar to your environment Java classpath (e.g. export CLASSPATH="/path_to_swt_jar/swt.jar")
3. Download and setup jRuby 1.5.6 (rvm install jruby -v1.5.6)
4. Install bundler (gem install bundler)
5. Install project required gems (bundle install)
6. Write a program that requires the file "lib/glimmer.rb" (or glimmer gem) and has the UI class (view) include the Glimmer module
7. Run your program with jruby (pass -J-XstartOnFirstThread option if on the Mac)

Samples
---
Check the "samples" folder for examples on how to write Glimmer applications.

Mac Support
---
In order to run Glimmer on the Mac, you need to pass an extra option to JRuby. For example:
jruby -J-XstartOnFirstThread samples/hello_world.rb

Background
---
Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

Resources
---
* [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [RubyConf 2008 Video](http://rubyconf2008.confreaks.com/desktop-development-with-glimmer.html)
* [Code Painter Blog](http://andymaleh.blogspot.com/search/label/Glimmer)

Contributors
---
* Annas "Andy" Al Maleh (Founder)
* Dennis Theisen

License
---
Copyright (c) 2011 Annas Al Maleh.
See LICENSE.txt for further details.
