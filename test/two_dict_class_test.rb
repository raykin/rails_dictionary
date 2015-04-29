require File.expand_path('test_helper', File.dirname(__FILE__))

Dictionary.acts_as_dictionary
Lookup.acts_as_dictionary
class Lookup::Major < Lookup; end

module TestTwoDictClass
  class TestLookUp < TestSupporter

    def prepare_data
      @art = Lookup.create!(name: 'art', type: 'Lookup::Major')
      @math = Lookup.create!(name: 'math', type: 'Lookup::Major')
    end

    def test_default_dclass_is_dictionary
      assert_equal Dictionary, RailsDictionary.dclass
    end

    def test_student_major_array
      Student.acts_as_dict_consumer on: :major_array, relation_type: :many_to_many, class_name: 'Lookup::Major'
      prepare_data
      s = Student.new(major_array_name: ['art', 'math'])
      s.save!; s.reload
      assert_equal([@art.id, @math.id], s.major_array)
    end


  end
end
