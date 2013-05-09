class Dummy
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include AttributeChanger::Allower

  @@objects = []

  attr_reader :id
  attr_accessor :attr2
  attributes_allowed_for_step_change [:attr1, :attr3, :attr4]

  validates :attr1, presence: true, inclusion:{in: %w(foo bar baz boo)}
  validates :attr2, presence: true
  validates :attr3, presence: true, if: ->(ac){ ac.attr1 == 'boo' }
  validates :attr4, presence: true, if: ->(ac){ ac.attr3.present? }

  def initialize attributes={}
    attributes.each do |name, value|
      send "#{name}=", value
    end
    @id = @@objects.size + 1
    @@objects << self
  end

  class << self
    def find_by_id id
      @@objects.find{ |o| o.id == id }
    end
  end

  def attr1; @attr1 end
  def attr3; @attr3 end
  def attr4; @attr4 end

  def attr1= val
    @attr1_was = @attr1 if val != @attr1
    @attr1 = val
  end

  def attr3= val
    @attr3_was = @attr3 if val != @attr3
    @attr3 = val
  end

  def attr4= val
    @attr4_was = @attr4 if val != @attr4
    @attr4 = val
  end

  def persisted?
    false
  end

  def attributes
    attrs = {}
    %w(attr1 attr2 attr3 attr4).each{ |name| attrs[name] = send(name) }
    attrs
  end

  def save
    if valid?
      clear_changes
      true
    else
      false
    end
  end

  def reload
    @attr1 = @attr1_was if @attr1_was
    @attr3 = @attr3_was if @attr3_was
    @attr4 = @attr4_was if @attr4_was
    self
  end


  private

    def clear_changes
      @attr1_was = nil
      @attr3_was = nil
      @attr4_was = nil
    end
end
