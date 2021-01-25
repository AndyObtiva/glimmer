class Module
  alias append_features_without_glimmer append_features
  def append_features(mod)
    if self == Glimmer && mod == Object
      Glimmer::Config.logger.debug { 'Appending Glimmer to Singleton Class of main object (not appending to Object everywhere to avoid method pollution)' }
      TOPLEVEL_BINDING.receiver.singleton_class.include(self)
    else
      append_features_without_glimmer(mod)
    end
  end
end
