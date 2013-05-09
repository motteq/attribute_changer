class AttributeChanger::Performer
  attr_reader :obj, :error, :result, :attrib, :attrib_change

  def initialize(attribs)
    @obj = attribs[:obj]
    @attrib = attribs[:attrib]
    @value = attribs[:value]
  end

  def save
    valid
    return false if result && !result.success
    create_attribute_change
    @result = AttributeChanger::Utils::Result.new true, nil
    true
  end


  private

    def attrib_exists?
      (@obj.attributes.keys - %w(id created_at updated_at)).include? @attrib.to_s
    end

    def attribute_allowed?
      @obj.class.attributes_allowed_for_step_change.include? @attrib
    end

    #BEGIN validation
    def valid
      unless attribute_allowed?
        @result = AttributeChanger::Utils::Result.new false, :not_allowed
        return
      end

      unless attrib_exists?
        @result = AttributeChanger::Utils::Result.new false, :missing_attribute
        return
      end

      if same_value?
        @result = AttributeChanger::Utils::Result.new false, :same
        return
      end

      unless valid_attrib?
        assign_error
        reset_obj
        @result = AttributeChanger::Utils::Result.new false, :invalid
        return
      end
    end

    def valid_attrib?
      @obj.send "#{@attrib}=", @value
      @obj.valid?
      @obj.errors[@attrib].empty?
    end

    def same_value?
      @obj.send(@attrib) == @value
    end

    def assign_error
      @error = @obj.errors[@attrib].first
    end

    def reset_obj
      @obj.errors.clear
      @obj.reload
    end
    # END validation

    def create_attribute_change
      @attrib_change = AttributeChanger::AttributeChange.new do |o|
        o.obj = @obj
        o.attrib = @attrib
        o.value = @value
      end
      @attrib_change.save!
    end
end
