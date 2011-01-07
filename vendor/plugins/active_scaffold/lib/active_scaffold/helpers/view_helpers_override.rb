# Need to open the AS module carefully due to Rails 2.3 lazy loading
ActiveScaffold::Helpers::ViewHelpers.module_eval do
  # Add the export plugin includes

  # Provides stylesheets to include with +stylesheet_link_tag+
  def active_scaffold_stylesheets_with_export(frontend = :default)
    active_scaffold_stylesheets_without_export.to_a << ActiveScaffold::Config::Core.asset_path("export-stylesheet.css", frontend)
  end
  alias_method_chain :active_scaffold_stylesheets, :export

  # Provides stylesheets for IE to include with +stylesheet_link_tag+
  def active_scaffold_ie_stylesheets_with_export(frontend = :default)
    active_scaffold_ie_stylesheets_without_export.to_a << ActiveScaffold::Config::Core.asset_path("export-stylesheet-ie.css", frontend)
  end
  alias_method_chain :active_scaffold_ie_stylesheets, :export

end
