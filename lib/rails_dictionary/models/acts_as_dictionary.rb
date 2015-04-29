module RailsDictionary
  module ActsAsDictionary
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end

    # is it worth to setup these workaround to make it auto load STI class?
    # these workaround are binding too deep with rails
    module ClassMethods

      # workaround seems more better than new
      def subclass_from_attributes(attrs)
        subclass_name = attrs.with_indifferent_access[inheritance_column]
        RailsDictionary.init_dict_sti_class(subclass_name) if subclass_name
        super
      end

      def find_sti_class(type_name)
        RailsDictionary.init_dict_sti_class(type_name)
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
