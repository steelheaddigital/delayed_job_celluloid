Rails.application.routes.draw do
  get "work" => "work#index"
  get "work/email" => "work#email"
  get "work/crash" => "work#crash"
end
