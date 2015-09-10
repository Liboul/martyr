module Martyr
  module Runtime
    # This is a SubCube builder. The builder method is #execute.
    # It takes the `select`, `slice`, and `granulate` clauses, makes sure they are well defined, and create a sub cube
    # as a result of their application.
    class QueryContextBuilder

      include Martyr::LevelComparator
      include Martyr::Translations

      attr_reader :cube
      delegate :elements, :facts, :pivot, to: :build

      def initialize(cube)
        @cube = cube
        @select_args_by_cube = {}
        @data_slice = {}
        @granulate_args = []
      end

      # select(:a, :b, :c)
      def select(*arr)
        dup.instance_eval do
          standardize(arr).each do |metric_id|
            cube_name = first_element_from_id(metric_id)
            @select_args_by_cube[cube_name] ||= []
            @select_args_by_cube[cube_name] << metric_id
          end
          self
        end
      end

      # Variant 1 - full slice as one hash:
      #   slice('artist.name' => {with: 'AC/DC'}, 'genre.name' => {with: 'Rock'}, quantity: {gt: 0})
      #
      # Variant 2 - on one dimension or metric
      #   slice('artist.name', with: 'AC/DC')
      #
      def slice(*several_variants)
        dup.instance_eval do
          if several_variants.length == 1 and several_variants.first.is_a?(Hash)
            several_variants.first.stringify_keys.except(PivotCell::METRIC_COORD_KEY).each do |slice_on, slice_definition|
              @data_slice.merge! standardize(slice_on) => slice_definition
            end
          elsif several_variants.length == 2
            slice_on, slice_definition = several_variants
            @data_slice.merge! standardize(slice_on) => slice_definition
          else
            ArgumentError.new("wrong number of arguments (#{several_variants.length} for 1..2)")
          end
          self
        end
      end

      # granulate('artist.name', 'genre.name')
      def granulate(*arr)
        dup.instance_eval do
          @granulate_args += arr
          self
        end
      end

      def build
        context = QueryContext.new
        setup_context_grain(context)
        setup_context_dimension_scopes(context)
        setup_context_sub_cubes_metrics_and_grain(context)
        setup_context_data_slice(context)
        decorate_all_scopes(context)
        context
      end

      private

      # = Building steps

      def setup_context_grain(context)
        if @granulate_args.present?
          context.level_ids_in_grain = @granulate_args
        else
          all_level_ids_from_cubes = cube.contained_cube_classes.flat_map do |cube_class|
            lowest_level_of(cube_class.level_associations).flat_map { |assoc| assoc.level_definition.level_and_above.map(&:id) }
          end
          context.level_ids_in_grain = all_level_ids_from_cubes.uniq
        end
      end

      def setup_context_sub_cubes_metrics_and_grain(context)
        cube.contained_cube_classes.index_by(&:cube_name).each do |cube_name, cube_class|
          sub_cube = Runtime::SubCube.new(context, cube_class)
          context.sub_cubes_hash[cube_name] = sub_cube
          if @select_args_by_cube.present?
            sub_cube.set_metrics(@select_args_by_cube[cube_name])
          else
            sub_cube.set_all_metrics
          end
          sub_cube.set_grain(@granulate_args)
          sub_cube.set_defaults_and_dependencies
        end
      end

      def setup_context_data_slice(context)
        @data_slice.each do |slice_on, slice_definition|
          context.data_slice.slice(slice_on, slice_definition)
        end
      end

      def setup_context_dimension_scopes(context)
        relevant_dimensions = context.level_ids_in_grain.map { |x| first_element_from_id(x) } + context.data_slice.dimension_names
        context.dimension_scopes = cube.build_dimension_scopes(relevant_dimensions.uniq)
      end

      def decorate_all_scopes(context)
        context.data_slice.add_to_dimension_scope(context)
        context.sub_cubes_hash.each do |cube_name, sub_cube|
          context.data_slice.for_cube_name(cube_name) { |scoped_data_slice| sub_cube.decorate_all_scopes(scoped_data_slice) }
        end
      end

      private

      def standardize(object)
        @standardizer ||= Martyr::MetricIdStandardizer.new(cube.contained_cube_classes.first.cube_name,
          raise_if_not_ok: cube.contained_cube_classes.length > 1)

        @standardizer.standardize(object)
      end

    end
  end
end
