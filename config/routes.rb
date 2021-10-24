Rails.application.routes.draw do

  resources :contact do
    collection do
      get :all_active
      post :new_contact
      put :update_contact
      put :soft_delete
    end
  end
end
