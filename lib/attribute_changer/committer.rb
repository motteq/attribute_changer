class AttributeChanger::Committer
  attr_reader :result, :error, :invalid_attribs

  def initialize(attribute_change)
    @result = AttributeChanger::Utils::Result.new nil, nil
    @attribute_change = attribute_change
  end

  def attrib_change; @attribute_change end

  def accept
    if update_obj
      @result.success = true
    else
      @result.success = false
      false
    end
  end

  def reject
    update_status :rejected
  end


  private

    def update_obj
      @obj = @attribute_change.obj
      @obj.send "#{@attribute_change.attrib}=", @attribute_change.value
      return update_status(:accepted) if @obj.save
      assign_error
      assign_invalid_attribs
      if @obj.errors[@attribute_change.attrib].any?
        return update_status(:accepted) if take_into_consideration_waiting_changes
        @result.message = :invalid_attrib
      else
        return update_status(:accepted) if take_into_consideration_waiting_changes
        @result.message = :invalid_obj
        update_status :waiting
      end
      false
    end

    def update_status(status)
      @attribute_change.status = status.to_s
      @attribute_change.save!
    end

    def assign_error
      @error = @obj.class.human_attribute_name(@obj.errors.first.first) + ' ' + @obj.errors.first.last
    end

    def assign_invalid_attribs
      @invalid_attribs = @obj.errors.messages.map{ |attr, errors| attr if errors.any? }.compact
    end

    def take_into_consideration_waiting_changes
      attrib_changes = AttributeChanger::AttributeChange.from_obj(@obj).waiting.all
      attrib_changes.each{ |ac| @obj.send "#{ac.attrib}=", ac.value }
      saved = @obj.save
      if saved
        attrib_changes.each do |ac| 
          ac.status = 'accepted'
          ac.save!
        end
      end
      saved
    end
end
