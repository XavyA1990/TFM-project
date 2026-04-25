module AdminTenants
  class UsersServices
    PER_PAGE = 15

    def initialize(action, params, repository: UsersRepository)
      @action = action
      @params = params
      @repository = repository
      @tenant = params[:tenant]
      @user = repository.find_by_slug_in_tenant(params[:slug], @tenant) if params[:slug].present?
    end

    def call
      return get_users_for_index if @action == :index
      return get_user_for_show_page if @action == :show
      return get_user if @action == :get

      raise ArgumentError, "Invalid action"
    end

    private

    def get_users_for_index
      paginated_users = PaginationService.new(
        relation: @repository.all_for_tenant_with_tenants_and_roles(@tenant),
        page: @params[:page],
        per_page: PER_PAGE
      ).call

      {
        rows: paginated_users[:rows].map do |user|
          {
            slug: user.slug,
            full_name: user.full_name,
            email: user.email,
            tenant_role: tenant_roles_summary(user) || "-",
            created_at: I18n.l(user.created_at),
            updated_at: I18n.l(user.updated_at)
          }
        end,
        current_page: paginated_users[:current_page],
        per_page: paginated_users[:per_page],
        total_count: paginated_users[:total_count],
        total_pages: paginated_users[:total_pages]
      }
    end

    def get_user_for_show_page
      [
        [I18n.t("admin.users.index.full_name"), @user.full_name],
        [User.human_attribute_name(:username), @user.username],
        [User.human_attribute_name(:first_name), @user.first_name],
        [User.human_attribute_name(:last_name), @user.last_name],
        [User.human_attribute_name(:email), @user.email],
        [User.human_attribute_name(:created_at), @user.created_at ? I18n.l(@user.created_at) : nil],
        [User.human_attribute_name(:updated_at), @user.updated_at ? I18n.l(@user.updated_at) : nil]
      ]
    end

    def get_user
      @user
    end

    def tenant_roles_summary(user)
      membership = user.users_tenants.find { |users_tenant| users_tenant.tenant_id == @tenant.id }
      return nil unless membership.present?

      "#{@tenant.name} (#{membership.roles.map(&:name).join(', ')})".presence
    end
  end
end
