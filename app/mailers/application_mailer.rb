# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch(
    "MAILER_FROM",
    "ClientFlow CRM <onboarding@resend.dev>"
  )

  layout "mailer"
end