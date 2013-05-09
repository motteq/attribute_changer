FactoryGirl.define do
  factory :attribute_change, class: AttributeChanger::AttributeChange do
    obj{ Dummy.new({attr1: 'foo', attr2: true}) }
    attrib 'attr1'
    value 'bar'
  end
end