require File.expand_path('test_helper', File.dirname(__FILE__))

module TestLookup

  class TestAsDictionary < TestSupporter

    def prepare_data
      @art = Lookup.create!(name: 'art', type: 'Lookup::Major')
      @math = Lookup.create!(name: 'math', type: 'Lookup::Major')
    end

    def setup
      RailsDictionary.config.dictionary_klass = :Lookup
      Lookup.acts_as_dictionary
      super
    end

    def test_lookup
      prepare_data
      assert Lookup, Lookup::Major.superclass
    end

    def test_student_major_array
      Student.acts_as_dict_consumer on: :major_array, relation_type: :many_to_many, class_name: 'Lookup::Major'
      prepare_data
      s = Student.new(major_array_name: ['art', 'math'])
      s.save!; s.reload
      assert_equal([@art.id, @math.id], s.major_array)
    end

    def test_student_with_majors
      Student.acts_as_dict_consumer on: :majors, relation_type: :many_to_many
      prepare_data
      s = Student.new(majors_name: ['art', 'math'])
      s.save!; s.reload
      assert_equal([@art.id, @math.id], s.majors)
      assert_equal ['art', 'math'], s.named_majors
    end
  end
end
