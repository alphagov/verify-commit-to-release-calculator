Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'release_time#index'
  get '/:repo', to: 'release_time#show', as: :repo
end
