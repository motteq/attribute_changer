module AttributeChanger::Allower
  extend ActiveSupport::Concern

  included do
    class_attribute :_attributes_allowed_for_step_change
  end

  module ClassMethods
    def attributes_allowed_for_step_change(attribs = nil)
      self._attributes_allowed_for_step_change ||= []
      self._attributes_allowed_for_step_change = *attribs if attribs
      _attributes_allowed_for_step_change
    end
  end
end