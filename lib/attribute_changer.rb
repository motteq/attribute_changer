module AttributeChanger
end

require 'active_record' unless defined?(ActiveRecord)
require 'active_support/concern' unless defined?(ActiveSupport::Concern)

require "attribute_changer/version"
require 'attribute_changer/committer'
require 'attribute_changer/performer'
require 'attribute_changer/allower'
require 'attribute_changer/attribute_change'
require 'attribute_changer/utils/result'
