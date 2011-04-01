# edit to add more packages and support custom widgets
class RWidget
  class << self
    def add_packages(*pkgs)
      (@packages||=[]).concat(pkgs)
      module_eval pkgs.map{|pkg| %|include_package "#{pkg}"|}.join("\n")
    end

    def swt_widget(widget_name)
      if widget_name =~ /(^[A-Z]\w*)$/
        @packages.each do |pkg|
          begin
            return Object.module_eval(pkg).__send__($1)
          rescue NameError
          end
        end
        raise NameError.new
      else
        raise NameError.new
      end
    end
  end
end

RWidget.add_packages('org.eclipse.swt',
                    'org.eclipse.swt.layout',
                    'org.eclipse.swt.custom',
                    'org.eclipse.swt.widgets')
