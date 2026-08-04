# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled =
    ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.assets.compile = false
  config.active_storage.service = :local

  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"

  config.log_level = :info
  config.log_tags = [:request_id]

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST"),
    protocol: ENV.fetch("APP_PROTOCOL", "https")
  }

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    domain: ENV.fetch("SMTP_DOMAIN"),
    user_name: ENV.fetch("SMTP_USERNAME"),
    password: ENV.fetch("SMTP_PASSWORD"),
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
    enable_starttls_auto: true,
    open_timeout: 5,
    read_timeout: 5
  }

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false

  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter

    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end