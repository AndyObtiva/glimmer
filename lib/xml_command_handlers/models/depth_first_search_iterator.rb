class DepthFirstSearchIterator
  def initialize(node, node_visitor)
    @node = node
    @node_visitor = node_visitor
  end
  
  def iterate
    process(@node)
  end
  
  def process(node)
    @node_visitor.process_before_children(node)
    node.children.each { |child| process(child) } unless node.is_a?(String)
    @node_visitor.process_after_children(node)
  end
  
end
