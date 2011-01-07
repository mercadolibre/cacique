require 'gettext/utils'
require 'gettext/tools'
#
#require 'gettext_rails/tools'
desc "Create mo-files"
task :makemo do
 GetText.create_mofiles(true, "po", "locale")
end

desc "Update pot/po files to match new version."
task :updatepo do
 TEXT_DOMAIN = "cacique"
 APP_VERSION     = "cacique 1.1.0"
 GetText.update_pofiles(TEXT_DOMAIN,
                        Dir.glob("{app,lib}/**/*.{rb,rhtml,haml,js}"),
                        APP_VERSION)
end