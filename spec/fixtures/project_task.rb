class ProjectTask < Struct.new(:name, :project, :priority)
  def project_name
    project.name
  end
  
  def project_name=(value)
    project.name = value
  end
  
  def hash
    priority.hash + project.hash * 16 + name.hash * 256
  end
  
  def ==(other)
    other.respond_to?(:name) && name == other.name && project == other.project && priority == other.priority
  end
  alias eql? ==
end
