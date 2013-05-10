# AttributeChanger

Allows step change for attributes.

## Installation

Add this line to your application's Gemfile:

    gem 'attribute_changer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attribute_changer

## Usage

Create and run migration:

```console
rails g attribute_changer
rake db:migrate
```

Example usage:

```ruby
class Dummy < ActiveRecord::Base
  include AttributeChanger::Allower

  attributes_allowed_for_step_change [:attr1, :attr2]

  validates :attr1, presence: true, inclusion:{in: %w(foo bar)}
  validates :attr2, presence: true, if: ->(obj){ obj.attr1 == 'bar' }
  validates :attr3, presence: true
end

dummy = Dummy.create do |obj|
  obj.attr1 = 'foo'
  obj.attr3 = false
end

performer = AttributeChanger::Performer.new obj: dummy, attrib: :attr3, value: true
performer.save  # false
performer.result.message  # :not_allowed

performer = AttributeChanger::Performer.new obj: dummy, attrib: :attr1, value: 'bar'
performer.save  # true

AttributeChanger::AttributeChange.from_obj(dummy).pending.count  # 1

committer = AttributeChanger::Committer.new performer.attrib_change
committer.accept  # false
committer.result.message  # :invalid_obj
committer.invalid_attribs  # [:attr2]

AttributeChanger::AttributeChange.from_obj(dummy).waiting.count  # 1

performer = AttributeChanger::Performer.new obj: dummy, attrib: :attr2, value: true
performer.save  # true

dummy.reload
dummy.attr1  # 'foo'
dummy.attr2  # nil

AttributeChanger::Committer.new(performer.attrib_change).accept  # true

dummy.reload
dummy.attr1  # bar
dummy.attr2  # true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
