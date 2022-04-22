class Dictionary < ActiveRecord::Base
  acts_as_dictionary
end

class DictType < ActiveRecord::Base
  acts_as_dict_type
end

# TODO: Here is a serious code loading issue. Student can't be load before DictType and Dictionary
class Student < ActiveRecord::Base
  acts_as_dict_slave
end
