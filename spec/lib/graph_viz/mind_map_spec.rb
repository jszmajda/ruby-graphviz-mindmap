require 'spec_helper'

describe GraphViz::MindMap do
  it "exists" do
    GraphViz::MindMap.should_not be_nil
  end

  describe "#build" do
    it "returns a Node" do
      map = GraphViz::MindMap.build "foo"
      map.should be_kind_of(GraphViz::MindMap::Node)
    end
  end

end
