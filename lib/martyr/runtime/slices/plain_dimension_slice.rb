module Martyr
  module Runtime
    class PlainDimensionSlice
      include Martyr::LevelComparator
      include ActiveModel::Validations


      # @attribute level [BaseLevelScope]
      attr_reader :level

      attr_reader :dimension_definition, :dimension_bus, :with, :without
      delegate :name, to: :level, prefix: true

      def initialize(dimension_definition, dimension_bus)
        @dimension_definition = dimension_definition
        @dimension_bus = dimension_bus
      end

      def inspect_part
        operator_inspection = [with ? "with: '#{with}'" : nil, without ? "without: '#{without}'" : nil].compact.join(' ')
        "#{dimension_name}: {level: '#{level_name}', #{operator_inspection}}"
      end

      validate do
        errors.add(:base, "Slice on `#{dimension_name}`: cannot have both `with` and `without`") if with and without
        errors.add(:base, "Slice on `#{dimension_name}`: must have either `with` and `without`") unless with or without
      end

      def dimension_name
        dimension_definition.name
      end

      # Sets the slice if this is the first time the dimension slice was referenced or if the level is equal to or lower
      # than the existing slice's level
      def set_slice(level:, with: nil, without: nil)
        @level = more_detailed_level(level, @level)
        return unless @level == level
        @with = with
        @without = without
      end

      def add_to_grain(grain)
        grain.add_granularity(level.id)
      end

      # Add to where has two distinct strategies:
      # FACT
      #   if the level is directly connected to the fact, it will perform the query directly on the fact.
      # JOIN
      #   otherwise, the common denominator will be saught

      # set_slice
      #   - if query - run the SQL and build cache
      #   - if degenerate - run the special set_slice_from_degenerate on the closest query
      # get_slice
      #   - if cache exists, use it
      #   - if cache does not exist:
      #     - if query - look at the slice above me to calculate my slice
      #     - if degenerate - look at the query and asks for get_slice

      # @param fact_scopes [Runtime::FactScopeCollection]
      def add_to_where(fact_scopes)
        scope_operator = FactScopeOperatorForDimension.new(dimension_name, level_name) do |operator|
          common_denominator_level = operator.common_denominator_level(level)

          if common_denominator_level.name == level_name and level.degenerate?
            add_to_where_using_fact_strategy(operator)
          else
            add_to_where_using_join_strategy(operator, common_denominator_level)
          end
        end
        fact_scopes.add_scope_operator(scope_operator)
      end

      def add_to_where_using_fact_strategy(operator)
        level_key = operator.level_key_for_where(level.id)
        operator.decorate_scope do |scope|
          if with.present?
            scope.where(level_key => with)
          elsif without.present?
            scope.where.not(level_key => without)
          end
        end
      end

      def add_to_where_using_join_strategy(operator, common_denominator_level)
        dimension_bus.with_level_scope(level.id) do |level_scope|
          if with.present?
            level_scope.slice_with(with)
          elsif without.present?
            level_scope.slice_without(without)
          end unless level_scope.loaded?
        end

        dimension_bus.with_level_scope(common_denominator_level.id) do |common_level|
          operator.decorate_scope do |scope|
            level_key = operator.level_key_for_where(common_level.id)
            scope.where(level_key => common_level.keys)
          end
        end
      end

    end
  end
end