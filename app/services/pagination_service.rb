class PaginationService
  def initialize(relation:, page:, per_page:)
    @relation = relation
    @page = page.to_i
    @per_page = per_page.to_i
  end

  def call
    current_page = @page < 1 ? 1 : @page
    per_page = @per_page < 1 ? 15 : @per_page
    total_count = @relation.count
    total_pages = (total_count.to_f / per_page).ceil

    {
      rows: @relation.limit(per_page).offset((current_page - 1) * per_page),
      current_page: current_page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages
    }
  end
end
