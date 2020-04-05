class Module
  # TODO improve this (make it work dynamically per DSL loaded)
  begin
    instance_method(:const_missing_without_glimmer)
  rescue
    alias const_missing_without_glimmer const_missing

    def const_missing(constant)
      return const_missing_without_glimmer(constant) if defined?(@const_missing_without_glimmer_constant) && @const_missing_without_glimmer_constant
      @const_missing_without_glimmer_constant = constant
      ::Glimmer::SWT.const_get(constant)
    rescue LoadError => e
      const_missing_without_glimmer(constant)
    rescue => e
      const_missing_without_glimmer(constant)
    ensure
      @const_missing_without_glimmer_constant = nil
    end
  end
end
