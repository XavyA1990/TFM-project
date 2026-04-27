module Users
  class ProfileServices
    def initialize(action, params, repository: UsersRepository)
      @action = action
      @params = params
      @repository = repository
      @user = params[:user]
    end

    def call
      return update if @action == :update

      raise ArgumentError, "Invalid action"
    end

    private

    def update
      @repository.update_with_password(@user, @params[:attributes])
    end
  end
end
