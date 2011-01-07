# Need to open the AS module carefully due to Rails 2.3 lazy loading
ActiveScaffold::Config::Core.class_eval do
  # For some note obvious reasons, the class variables need to be defined
  # *before* the cattr !!
  @@export_show_form = true
  @@export_allow_full_download = true
  @@export_default_full_download = true
  @@export_force_quotes = false
  @@export_default_skip_header = false
  @@export_default_delimiter = ','
  cattr_accessor :export_show_form, :export_allow_full_download,
      :export_force_quotes, :export_default_full_download,
      :export_default_delimiter, :export_default_skip_header

  ActionController::Resources::Resource::ACTIVE_SCAFFOLD_ROUTING[:collection][:show_export] = :get
end
