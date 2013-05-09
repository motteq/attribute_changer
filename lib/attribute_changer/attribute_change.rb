class AttributeChanger::AttributeChange < ::ActiveRecord::Base
  self.table_name_prefix = 'attribute_changer_'

  attr_accessible nil

  validates :obj_id, presence: true
  validates :obj_type, presence: true
  validates :attrib, presence: true
  validates :status, presence: true, inclusion:{in: %w(obsolete pending rejected accepted waiting)}

  after_initialize :set_default_values
  after_create :change_status

  class << self
    def from_obj(obj); where("obj_type = ? AND obj_id = ?", obj.class.name, obj.id) end
    def pending; where("status = ?", 'pending') end
    def waiting; where("status = ?", 'waiting') end
  end

  def obj_type
    if val = read_attribute(:obj_type)
      val.constantize
    end
  end

  def obj
    if obj_type && obj_id
      @obj ||= obj_type.find_by_id obj_id
    end
  end

  def obj=(val)
    self.obj_id = val.id
    self.obj_type = val.class.to_s
  end

  def value=(val)
    write_attribute :value, serialize(val)
  end

  def value
     deserialize
  end

  def dependent_attribs(o = obj)
    attrib_was = o.send "#{attrib}"
    o.send "#{attrib}=", value
    o.valid?
    da = o.errors.messages.map{|attr, errors| attr if errors.any?}.compact
    o.send "#{attrib}=", attrib_was
    o.valid?
    da
  end


  private

    def set_default_values
      self.status ||= 'pending'
    end

    def change_status
      self.class.where('obj_id = ?', obj_id).where('obj_type = ?', obj_type.to_s).where('attrib = ?', attrib).
        where('status = ?', 'pending').where('created_at < ?', created_at).each do |o|
          o.update_attribute :status, 'obsolete'
      end
    end

    def serialize(val)
      Base64.encode64(Marshal.dump(val))
    end

    def deserialize
      Marshal.load Base64.decode64(read_attribute(:value))
    end
end
