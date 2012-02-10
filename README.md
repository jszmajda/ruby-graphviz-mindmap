# ruby-graphviz-mindmap

So this actually isn't using the ruby GraphViz library right now, but I mean to make it do so. It mostly just generates [dot][1] format files at the moment.

## Installation

You need [graphviz][2] installed. On ubuntu it's just `sudo apt-get install graphviz`

Then `gem install ruby-graphviz-mindmap`

## Usage

Create a script in which you layout your mind map:

    require 'ruby-graphviz-mindmap'
    map = GraphViz::MindMap.build "foo", overlap: false
    map.node 'baz', color: :red, shape: :box do
      node 'bar' do
        node 'ha'
      end 

      node 'two', color: :blue do
        inherit!
        node 'three' do
          node 'Four And'
          node 'ha', color: :green
        end 
      end 
    end 

    File.open('output.dot', 'wb'){|f| f << map.to_dot }

That will output a dot file ready for processing with a graphviz
command. I like `neato` for this ([documentation on neato][3]):

    neato -Tjpeg output.dot -o output.jpg

You'll get something that looks like this:

![output.jpg](http://haven.loki.ws/img/omap.jpg)


## Contributing to ruby-graphviz-mindmap
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Joshua Szmajda. See LICENSE.txt for
further details.

[1]: http://www.graphviz.org/pdf/dotguide.pdf
[2]: http://www.graphviz.org/
[3]: http://www.graphviz.org/pdf/neatoguide.pdf
