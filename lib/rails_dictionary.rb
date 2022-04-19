# rake tasks not autoload in Rails4
Dir[File.expand_path('../tasks/**/*.rake',__FILE__)].each { |ext| load ext } if defined?(Rake)

require File.join(File.dirname(__FILE__), "rails_dictionary/array_core_ext")

ActiveSupport.on_load :active_record do
  require File.join(File.dirname(__FILE__), "rails_dictionary/active_record_extension")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dict_type")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dictionary")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dict_slave")

  ::ActiveRecord::Base.send :include, RailsDictionary::ActiveRecordExtension
end
