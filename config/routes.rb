Rails.application.routes.draw do

  resources :contact do
    collection do
      get :all_active
      post :new_contact
    end
  end
end
