class ProjectTask < Struct.new(:name, :project, :priority)
  def project_name
    project.name
  end
  def project_name=(value)
    project.name = value
  end
end
