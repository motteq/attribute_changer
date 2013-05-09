require "spec_helper"

describe AttributeChanger::Committer do
  describe "attributes" do
    describe "result" do
      it "is instance of AttributeChanger::Utils::Result" do
        AttributeChanger::Committer.new(nil).result.should be_instance_of AttributeChanger::Utils::Result
      end
    end
  end

  describe "instance methods" do
    let(:dummy_obj){ Dummy.new attr1: 'foo', attr2: true }
    let(:performer){ AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'bar') }
    let(:committer){ AttributeChanger::Committer.new performer.attrib_change }

    before do 
      performer.save 
      dummy_obj.reload
    end

    describe "#accept" do
      before { committer.accept }

      context "change is valid" do
        it "changes status of attribute's change to accepted" do
          committer.attrib_change.reload.status.should eq "accepted"
        end

        it "changes attribute's value" do
          dummy_obj.reload.attr1.should == 'bar'
        end

        it "returns true" do
          performer = AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'baz')
          performer.save
          AttributeChanger::Committer.new(performer.attrib_change).accept.should be_true
        end
      end

      context "change is invalid" do
        let(:committer) do 
          attrib_change = performer.attrib_change
          attrib_change.value = 'buz'
          AttributeChanger::Committer.new attrib_change
        end

        it "leaves pending status" do
          committer.attrib_change.reload.status.should eq "pending"
        end

        it "does not change attribute's value" do
          dummy_obj.reload.attr1.should == 'foo'
        end

        it "returns false" do
          committer.accept.should be_false
        end

        it "has result attribute with success equals false" do
          committer.result.success.should be_false
        end

        it "has result attribute with proper message" do
          committer.result.message.should eq :invalid_attrib
        end

        it "assigns error attribute" do
          committer.error.should eq 'Attr1 is not included in the list'
        end
      end

      context "change is valid but whole object is invalid" do
        let(:performer){ AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr1, value: 'boo') }

        it "sets status to waiting" do
          committer.attrib_change.reload.status.should eq "waiting"
        end

        it "has result attribute with proper message" do
          committer.result.message.should eq :invalid_obj
        end

        it "allows to get invalid attributes through getter" do
          committer.invalid_attribs.should eq [:attr3]
        end

        context "changes for invalid attributes are waiting" do
          before do
            p1 = AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr3, value: 'foo')
            p1.save
            AttributeChanger::Committer.new(p1.attrib_change).accept  # false, :invalid_obj
            dummy_obj.attr3 = nil
            p2 = AttributeChanger::Performer.new(obj: dummy_obj, attrib: :attr4, value: 'foo')
            p2.save
            AttributeChanger::Committer.new(p2.attrib_change).accept
            committer.accept
          end

          it "takes into consideration all valid waiting changes and change status to accepted" do
            committer.attrib_change.reload.status.should eq "accepted"
          end

          it "changes status of waiting changes to accepted" do
            AttributeChanger::AttributeChange.waiting.count.should eq 0
          end
        end
      end
    end

    describe "#reject" do
      before { committer.reject }

      it "changes status of attribute's change to rejected" do
        committer.attrib_change.reload.status.should eq "rejected"
      end

      it "does not change attribute's value" do
        dummy_obj.attr1.should == 'foo'
      end
    end
  end
end
