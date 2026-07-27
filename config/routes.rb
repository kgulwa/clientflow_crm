# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :clients do
    resources :notes, only: %i[create destroy]
  end

  root 'home#index'
end