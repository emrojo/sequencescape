module ApiTools
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def render_class
      @render_class ||= Api::Base.render_class_for_model(self)
    end
  end

  def for_api(_options = {})
    self.class.render_class.to_hash(self)
  end

  def to_xml(options = {})
    renamed_keys = for_api.inject({}) do |renamed_keys, (key, value)|
      renamed_keys.tap { renamed_keys[key.underscore] = value }
    end
    options.reverse_merge!(root: self.class.to_s.underscore, skip_types: true)
    renamed_keys.to_xml(options)
  end

  def list_json(_options = {})
    self.class.render_class.to_hash_for_list(self)
  end

  # TODO: Add relationships for object
  def as_json(_options = {})
    { json_root => self.class.render_class.to_hash(self), 'lims' => configatron.amqp.lims_id! }
  end

  def to_yaml(options = {})
    for_api.to_yaml(options)
  end

  def url_name
    self.class.to_s.underscore
  end
  alias_method(:json_root, :url_name)

  def url
    [configatron.api_url, API_VERSION, url_name.pluralize, uuid].join('/')
  end
end

class ActiveRecord::Base
  include ApiTools
end
