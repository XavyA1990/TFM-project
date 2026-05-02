module Positioning
  class ReorderSiblings
    def initialize(action:, record:, siblings:, new_position: nil, repository: PositioningRepository)
      @record = record
      @siblings = siblings
      @new_position = new_position
      @repository = repository
      @action = action
    end

    def call
      return insert_into_siblings if %i[create insert_into_siblings].include?(@action)
      return move_within_siblings if %i[update move_within_siblings].include?(@action)
      return remove_from_siblings if %i[destroy remove_from_siblings].include?(@action)

      raise ArgumentError, "Invalid action"
    end

    private

    def insert_into_siblings
      max_position = insert_max_position
      target_position = normalized_position(max_position)

      @record.class.transaction do
        @repository.change_siblings_position(
          @siblings,
          target_position,
          max_position - 1,
          amount: 1,
          excluded_record: @record
        )

        @record = @repository.assign_position(@record, target_position)
      end

      @record
    end

    def move_within_siblings
      old_position = @record.position
      max_position = current_max_position
      target_position = normalized_position(max_position)

      return @record if old_position == target_position

      @record.class.transaction do
        if target_position < old_position
          @repository.change_siblings_position(
            @siblings,
            target_position,
            old_position - 1,
            amount: 1,
            excluded_record: @record
          )
        else
          @repository.change_siblings_position(
            @siblings,
            old_position + 1,
            target_position,
            amount: -1,
            excluded_record: @record
          )
        end

        @record = @repository.update_position(@record, target_position)
      end

      @record
    end

    def remove_from_siblings
      old_position = @record.position
      max_position = current_max_position

      @record.class.transaction do
        @repository.change_siblings_position(
          @siblings,
          old_position + 1,
          max_position,
          amount: -1,
          excluded_record: @record
        )
      end

      @record
    end

    def normalized_position(max_position)
      return max_position if @new_position.blank?

      requested_position = @new_position.to_i
      [[requested_position, 1].max, max_position].min
    end

    def current_max_position
      @repository.maximum_position(@record, @siblings)
    end

    def insert_max_position
      current_max_position + 1
    end
  end
end
