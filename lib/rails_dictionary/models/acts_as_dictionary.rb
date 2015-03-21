module RailsDictionary
  module ActsAsDictionary
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end

    module ClassMethods

      # override to make sure STI class init first
      def new(opts)
        type_opt = opts.with_indifferent_access[inheritance_column]
        RailsDictionary.init_dict_sti_class(type_opt) if type_opt
        super
      end

    end # End ClassMethods

    module InstanceMethods
      def type=(name)
        ::RailsDictionary.init_dict_sti_class(name)
        super
      end
    end # End InstanceMethods

  end
end
