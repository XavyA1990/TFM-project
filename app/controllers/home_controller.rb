class HomeController < ApplicationController
  def index
    @tenants = Home::TenantsServices.new(:index).call
  end
end
