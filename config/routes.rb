Rails.application.routes.draw do
  root "pages#home"
  devise_for :users

  resource :cart, only: [ :show ] do
    post "add/:product_id", to: "carts#add", as: "add_to"
    delete "remove/:product_id", to: "carts#remove", as: "remove_from"
    patch ":id", to: "carts#update_quantity", as: "update_quantity"
  end

  resources :users, only: [ :index ]

  resource :user, only: [ :show ] do
    resources :orders, only: [ :show ]
  end

  resources :products, only: [ :index, :show, :new, :create ]
  resources :orders, only: [ :index, :show, :create ]
  resources :reviews, only: [ :index, :create, :destroy ]

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
