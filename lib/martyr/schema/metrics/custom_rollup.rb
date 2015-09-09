module Martyr
  module Schema
    class CustomRollup < BaseMetric
      include ActiveModel::Model

      attr_accessor :cube_name, :name, :block

      def build_data_slice(*)
        raise Runtime::Error.new("Rollups cannot be sliced: attempted on rollup `#{name}`")
      end

      def build_memory_slice(*)
        raise Runtime::Error.new("Rollups cannot be sliced: attempted on rollup `#{name}`")
      end

      # @param fact_scopes [Runtime::FactScopeCollection]
      def add_to_select(fact_scopes)
        # no-op
      end

      def extract(fact)
        raise Runtime::Error.new("Rollups cannot be extracted: attempted on rollup `#{name}`")
      end

      # @override
      # @param element [Runtime::Element]
      def rollup(element)
        catch(:empty_element) do
          block.call Runtime::RollupFactSet.new(cube_name, name, element)
        end
      end

    end
  end
end
