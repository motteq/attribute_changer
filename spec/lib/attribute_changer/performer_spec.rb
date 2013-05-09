require 'spec_helper'

describe AttributeChanger::Performer do
  describe "instance methods" do
    describe "#save" do
      let(:dummy_obj){ Dummy.new attr1: 'foo' }

      it "sets Utils::Result object to result attribute" do
        ac = AttributeChanger::Performer.new({obj: dummy_obj, attrib: :attr1, value: 'bar'})
        ac.save
        ac.result.should be_instance_of AttributeChanger::Utils::Result
      end

      context "value is allowed" do
        context "new value is valid" do
          context "new value if different" do
            it "creates attribute's change object" do
              AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'bar').save
              AttributeChanger::AttributeChange.count.should eq 1
            end
          end
          context "new value is the same" do
            it "does not create attribute's change object" do
              AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'foo').save
              AttributeChanger::AttributeChange.count.should eq 0
            end
          end
        end

        context "new value is invalid" do
          let(:attribute_changer){ AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'buz') }

          before{ attribute_changer.save }

          it "assigns error attribute" do
            attribute_changer.error.should eq "is not included in the list"
          end

          it "do not change the object" do
            attribute_changer.obj.attr1.should eq 'foo'
          end

          it "do not assign error to object" do
            attribute_changer.obj.errors.should be_empty
          end
        end
      end

      context "value is not allowed" do
        subject{ AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr2, value: 'foo') }

        before{ subject.save }

        it("returns false") { subject.save.should be_false }

        it("has result with success attribute equals false") { subject.result.success.should be_false }

        it("has result with proper message") { subject.result.message.should == :not_allowed }
      end
    end
  end
end
