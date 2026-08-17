# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users,
              controllers: {
                registrations: "users/registrations" }

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

  resources :workspace_invitations, only: %i[index create destroy]
  resources :workspace_members, only: %i[update destroy]

  get "workspace_invitations/:token/accept",
      to: "workspace_invitations#accept",
      as: :accept_workspace_invitation

  root "home#index"
end