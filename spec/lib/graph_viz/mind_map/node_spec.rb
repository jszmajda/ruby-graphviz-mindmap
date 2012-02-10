require 'spec_helper'

describe GraphViz::MindMap::Node do
  it "exists" do
    GraphViz::MindMap::Node.should_not be_nil
  end

  describe "#initialize" do
    it "initializes with a graph name" do
      map = GraphViz::MindMap::Node.new "foo"
      map.name.should == "foo"
    end

    it "initializes with options" do
      map = GraphViz::MindMap::Node.new "foo", a: 2
      map.options[:a].should == 2
    end
  end

  let(:node) do
    GraphViz::MindMap::Node.new "foo", a: 2
  end

  let(:spaced_node) do
    GraphViz::MindMap::Node.new "Some Thing", a: 4, shape: :box
  end

  let(:weird_node) do
    GraphViz::MindMap::Node.new "dumb   other thing ++?* !"
  end

  let(:complex_graph) do
    base = GraphViz::MindMap::Node.new "foo", overlap: false
    base.node 'baz', color: :red do
      node 'bar' do
        node 'ha'
      end

      node 'two', color: :blue do
        node 'three' do
          node 'Four And'
          node 'ha'
        end
      end
    end
    base
  end

  let(:graph_with_carries) do
    base = GraphViz::MindMap::Node.new "foo", overlap: false
    base.node 'baz', color: :red, shape: :box do
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
    base
  end

  describe "#dot_identifier" do
    it "outputs something dot understands" do
      node.dot_identifier.should == 'foo'
      spaced_node.dot_identifier.should == 'some_thing'
      weird_node.dot_identifier.should == 'dumb_other_thing'
    end

    it "doesn't cross names when multiple nodes exist in the same tree with the same name" do
      map = complex_graph
      map.at('0.0.0').name.should == 'ha'
      map.at('0.1.0.1').name.should == 'ha'
      map.at('0.0.0').dot_identifier.should == 'ha'
      map.at('0.1.0.1').dot_identifier.should == 'three_ha'
    end
  end

  describe "#dot_options" do
    it "outputs something dot understands" do
      node.dot_options.should == '[a="2"]'
      spaced_node.dot_options.should == '[a="4" shape="box"]'
      weird_node.dot_options.should == ''
    end
  end

  describe "#node_def" do
    it "outputs the correct definitions" do
      node.node_def.should == 'foo [a="2"]'
      spaced_node.node_def.should == 'some_thing [a="4" shape="box"]'
      weird_node.node_def.should == 'dumb_other_thing'
    end
  end

  describe "#node" do
    it "creates a child node" do
      base = GraphViz::MindMap::Node.new "foo"
      base.node 'bar'

      base.nodes.first.name.should == 'bar'
    end

    it "creates a child node with options too" do
      base = GraphViz::MindMap::Node.new "foo"
      base.node 'bar', color: :red

      base.nodes.first.options[:color].should == :red
    end

    describe "block builder syntax" do
      it "constructs a tree" do
        base = GraphViz::MindMap::Node.new "foo"
        base.node 'baz' do
          node 'bar'
        end

        base.nodes.first.name.should == 'baz'
        base.nodes.first.nodes.first.name.should == 'bar'
      end

      it "makes a complex graph" do
        base = complex_graph

        base.nodes.size.should == 1
        base.nodes.first.name.should == 'baz'
        base.nodes.first.nodes.size.should == 2
        base.nodes.first.nodes.first.name.should == 'bar'
        base.nodes.first.nodes.first.nodes.first.name.should == 'ha'
        base.nodes.first.nodes.last.name.should == 'two'
        base.nodes.first.nodes.last.nodes.first.name.should == 'three'
        base.nodes.first.nodes.last.nodes.first.nodes.first.name.should == 'Four And'
      end
    end
  end

  it "allows dot-index mapping into the tree" do
    complex_graph.at('0.1.0.1').name.should == 'ha'
  end

  describe "inheriting options" do
    it "assigns the same options to its children when inerhit! is called" do
      map = graph_with_carries
      map.at('0.1.0').options[:color].should == :blue
      map.at('0.1.0.0').options[:color].should == :blue
      map.at('0.1.0.1').options[:color].should == :green
    end
  end

  describe "the whole shebang" do
    it "converts the complex_graph into the right dot syntax" do
      expected = <<-EOT.chop
graph foo {
  graph [overlap="false"]
  baz [label="baz" color="red" shape="box"]
  subgraph sg_baz {
    bar [label="bar"]
    baz -- bar
    subgraph sg_bar {
      ha [label="ha"]
      bar -- ha
    }
    two [label="two" color="blue"]
    baz -- two
    subgraph sg_two {
      three [label="three" color="blue"]
      two -- three
      subgraph sg_three {
        four_and [label="Four And" color="blue"]
        three -- four_and
        three_ha [label="ha" color="green"]
        three -- three_ha
      }
    }
  }
}
      EOT
      graph_with_carries.to_dot.should == expected
      File.open("/tmp/out.dot",'wb'){|f| f << graph_with_carries.to_dot }
    end

  end
end
