# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
 ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.9' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration

require File.join(File.dirname(__FILE__), 'boot')

ENV['HOME'] = RAILS_ROOT unless ENV['HOME']

$LOAD_PATH << RAILS_ROOT

#STARLING_PORT = 22122

# configuracion de rails-authorization-plugin
AUTHORIZATION_MIXIN = "object roles"
PERMISSION_DENIED_REDIRECTION = "/users/access_denied"

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )


  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'Buenos Aires'


  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_cacique_session',
    :secret      => 'fda2aa5a03b5a5bba504d55d267dc3e42b98a973f971b748495a5c3a80b67384b96f88227991c834d4341ec50fede9cff1556820fcbee38c0b103a9e59b3ad24'
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.register_template_extension('haml')
  
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer



end

    CalendarDateSelect.format = :finnish
    
require File.dirname(__FILE__) + '/cacique_conf'

 ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
     :address  => EMAIL_SERVER,
     :user_name => EMAIL_USER_NAME,
     :password => EMAIL_PASS,
     :authentication => EMAIL_AUTH,
     :port  => EMAIL_PORT,
     :domain => EMAIL_DOMAIN,
  }

Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:short => '%d/%m/%Y')
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:short => '%H:%M - %d/%m/%Y')

