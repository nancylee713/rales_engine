Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      namespace :customers do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/invoices', to: "invoices#index"
        get '/:id/transactions', to: "transactions#index"
      end

      namespace :invoice_items do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/invoice', to: "invoice#show"
        get '/:id/item', to: "item#show"
      end

      namespace :invoices do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/transactions', to: "transactions#index"
        get '/:id/invoice_items', to: "invoice_items#index"
        get '/:id/items', to: "items#index"
        get '/:id/merchant', to: "merchant#show"
        get '/:id/customer', to: "customer#show"
      end

      namespace :items do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/merchant', to: "merchant#show"
        get '/:id/invoice_items', to: "invoice_items#index"
      end

      namespace :merchants do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/items', to: "items#index"
        get '/:id/invoices', to: "invoices#index"
        get '/:id/favorite_customer', to: "favorite_customer#show"
        get '/most_revenue', to: "revenue#index"
        get '/revenue', to: "revenue#show"
      end

      namespace :transactions do
        get '/find', to: "search#show"
        get '/find_all', to: "search#index"
        get '/random', to: "random#show"
        get '/:id/invoice', to: "invoice#show"
      end

      resources :customers, only: [:index, :show]
      resources :invoice_items, only: [:index, :show]
      resources :invoices, only: [:index, :show]
      resources :items, only: [:index, :show]
      resources :merchants, only: [:index, :show]
      resources :transactions, only: [:index, :show]
    end
  end
end
