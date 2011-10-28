class NodeVisitor
	def process_before_children
		raise "must be implemented by a class"
	end

	def process_after_children
		raise "must be implemented by a class"
	end
end