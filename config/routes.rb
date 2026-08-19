# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
              controllers: {
                registrations: "users/registrations"
              }

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
  resources :reports, only: :index

  resources :notifications, only: :index do
    member do
      patch :read
    end

    collection do
      patch :read_all
    end
  end

  resources :workspace_invitations, only: %i[index create destroy]
  resources :workspace_members, only: %i[update destroy]

  get "workspace_invitations/:token/accept",
      to: "workspace_invitations#accept",
      as: :accept_workspace_invitation

  root "home#index"
end