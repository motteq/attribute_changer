require 'spec_helper'

describe AttributeChanger::Allower do
  it "includes attributes_allowed_for_step_change class method" do
    Dummy.stub(:attributes_allowed_for_step_change){ |arg1| true }
    Dummy.attributes_allowed_for_step_change(:attrib1).should be_true
  end
end
