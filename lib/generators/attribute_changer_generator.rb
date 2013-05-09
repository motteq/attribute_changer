class AttributeChangerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc "Create migration"

  def copy_migration
    copy_file "create_attribute_changer_attribute_changes.rb", "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_create_attribute_changer_attribute_changes.rb"
  end
end
