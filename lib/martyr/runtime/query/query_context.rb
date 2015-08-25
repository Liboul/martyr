module Martyr
  module Runtime
    class QueryContext

      attr_accessor :sub_cubes, :dimension_scopes

      def initialize
        @sub_cubes = []
      end

      def inspect
        "#<QueryContext @sub_cubes=#{sub_cubes}, @dimension_scopes=#{dimension_scopes}>"
      end

      # = As Dimension Bus Role

      # @param level_id [String]
      # @yieldparam [BaseLevelScope]
      def with_level_scope(level_id)
        yield dimension_scopes.find_level(level_id)
      end

      def new_dimension_scope_operator(level_id)
        FactScopeOperatorForDimension.new()
      end

    end
  end
end
