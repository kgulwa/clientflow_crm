# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :clients do
    resources :notes, only: %i[create destroy]
    resources :tasks, only: %i[create update destroy]
    resources :tags, only: :create
    resources :client_tags, only: %i[create destroy]
    resources :contacts, except: :index
  end

  resources :leads

  resources :deals

  resources :tasks, only: :index

  root "home#index"
end