# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store

    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost"),
    port: ENV.fetch("APP_PORT", 3000).to_i,
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "smtp.resend.com"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    domain: ENV.fetch("SMTP_DOMAIN", "localhost"),
    user_name: ENV.fetch("SMTP_USERNAME", "resend"),
    password: ENV.fetch("SMTP_PASSWORD"),
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
    enable_starttls_auto: true,
    open_timeout: 15,
    read_timeout: 30
  }

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.assets.quiet = true
end