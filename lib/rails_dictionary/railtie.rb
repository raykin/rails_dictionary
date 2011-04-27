require 'rails'
require 'iconv'

require File.join(File.dirname(__FILE__),"array_core_ext")
require File.join(File.dirname(__FILE__),"models/acts_as_dict_type")
require File.join(File.dirname(__FILE__),"models/acts_as_dictionary")
require File.join(File.dirname(__FILE__),"models/acts_as_dict_slave")

module RailsDictionary
  class Railtie < ::Rails::Railtie
    initializer 'rails_dictionary' do |app|
      ActiveSupport.on_load(:active_record) do
        require File.join(File.dirname(__FILE__), 'models/active_record_extension')
        ::ActiveRecord::Base.send :include, RailsDictionary::ActiveRecordExtension
      end
    end
  end
end
