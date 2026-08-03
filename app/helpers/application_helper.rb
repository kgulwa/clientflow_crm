# frozen_string_literal: true

module ApplicationHelper
  def avatar_initials(name)
    return "?" if name.blank?

    name
      .split
      .first(2)
      .map { |part| part.first.upcase }
      .join
  end
end