Dowesd::Application.routes.draw do
  root :to => "static_pages#home"

  match "/about",   :to => "static_pages#about"
  match "/contact", :to => "static_pages#contact"

  resources :sessions, only: [:new, :create, :destroy]
  match "/signin",  to: "sessions#new"
  match "/signout", to: "sessions#destroy", via: :delete

  resources :users, only: [:index, :show, :edit, :update] do
    resources :accounts, only: [:index, :show, :create, :destroy]
  end

  resources :txns,  only: [:create, :destroy] do
    collection do
      get "descriptions"
    end
  end
end
