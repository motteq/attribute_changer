require 'spec_helper'

describe AttributeChanger::AttributeChange do
  describe "attributes" do
    it "has obj attribute" do
      subject.obj.should be_nil
    end

    describe "obj" do
      it "sets obj_type and obj_id from obj" do
        obj = Dummy.new attr1: 'foo', attr2: true
        subject.obj = obj
        subject.obj_id.should eq obj.id
        subject.obj_type.should eq Dummy
      end
    end

    describe "status" do
      it "has default value equals pending" do
        subject.status.should eq 'pending'
      end
    end

    describe "value" do
      it "is serialized" do
        ac = FactoryGirl.create :attribute_change, value: 'baz'
        AttributeChanger::AttributeChange.find(ac.id).value.should eql 'baz'
      end

      it "could be nil" do
        ac = FactoryGirl.create :attribute_change, value: nil
        AttributeChanger::AttributeChange.find(ac.id).value.should be_nil
      end
    end
  end

  describe "instance methods" do
    describe "#dependent_attribs" do
      it "returns dependent attributes"
    end
  end
end
