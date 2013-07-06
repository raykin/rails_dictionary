require 'iconv'

require File.join(File.dirname(__FILE__), "rails_dictionary/array_core_ext")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/active_record_extension")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/acts_as_dict_type")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/acts_as_dictionary")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/acts_as_dict_slave")

# rake tasks not autoload in Rails4
Dir[File.expand_path('../tasks/**/*.rake',__FILE__)].each { |ext| load ext } if defined?(Rake)

::ActiveRecord::Base.send :include, RailsDictionary::ActiveRecordExtension
