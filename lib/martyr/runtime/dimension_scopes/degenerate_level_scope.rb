module Martyr
  module Runtime
    class DegenerateLevelScope < BaseLevelScope

      delegate :query_level_with_finder, :query_level_key, :register_element_helper_methods, to: :level
      delegate :nullify, to: :query_level_below

      def sliceable?
        !!query_level_below
      end

      def slice_with(values)
        query_level_below.decorate_scope do |scope|
          query_level_with_finder.call(scope, values)
        end
        query_level_below.set_bottom_sliced_level
      end

      def loaded?
        query_level_below.loaded?
      end

      # TODO: load from fact when sliceable? is false
      def load
        return true if loaded?
        query_level_below.load
        true
      end

      def all
        loaded_cache.keys
      end
      alias_method :keys, :all
      alias_method :all_values, :all

      # Useful when the fact is attempting to resolve Degenerate 1 value:
      #   Degenerate 1
      #         Degenerate 2    ----    Cube
      #               Query 3
      #
      # @return [String] the value of the "Degenerate 1" parent
      def recursive_lookup_up(degenerate_value, level:)
        return degenerate_value if name == level.name
        query_level_primary_key = query_level_below.record_primary_key(loaded_cache[degenerate_value])
        query_level_below.recursive_lookup_up(query_level_primary_key, level: level)
      end

      def recursive_lookup_down(degenerate_values, level:)
        degenerate_values = Array.wrap(degenerate_values)
        return degenerate_values if name == level.name
        query_level_records = degenerate_values.flat_map{|value| query_level_below.cached_records_by(query_level_key)[value]}
        query_level_below.recursive_lookup_down(query_level_records, level: level)
      end

      protected

      # The cache stored is basically one representative of the query level for each degenerate value.
      # Assuming the hierarchy is strict, i.e. the state parent of "San Francisco" is always "California", we are able
      # to infer correctly the hierarchy
      def cache
        @cache ||= query_level_below.all.index_by{|x| degenerate_value_from_query_record(x) }
      end

      def loaded_cache
        load and return cache
      end

      public

      def degenerate_value_from_query_record(record)
        record.send(query_level_key)
      end

    end
  end
end
