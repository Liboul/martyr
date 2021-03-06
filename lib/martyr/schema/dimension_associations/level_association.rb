module Martyr
  module Schema
    class LevelAssociation
      include Martyr::Level

      attr_accessor :level, :fact_key, :fact_alias, :sort
      alias_method :level_definition, :level

      # Important so that the to_i will take into account all levels defined for the dimension, not just the supported one
      delegate :to_i, to: :level

      delegate :label_key, :label_expression, to: :level

      # @param collection [LevelAssociationCollection]
      # @param level [BaseLevelDefinition]
      def initialize(collection, level, fact_key: nil, fact_alias: nil, sort: nil)
        @collection = collection
        @level = level
        @fact_key = fact_key || level.fact_key
        @fact_alias = fact_alias || level.fact_alias
        @sort = sort || level.sort
      end

      def supported?
        true
      end

      private

      # Delegate everything to level
      def method_missing(method_name, *args, &block)
        level.respond_to?(method_name) ? level.send(method_name, *args, &block) : super
      end

    end
  end
end
