module Martyr
  module Runtime
    class PivotCell

      attr_reader :metric_id, :metric_human_name, :element
      delegate :facts, to: :element

      def initialize(metric, element)
        @metric_id = metric.id
        @metric_human_name = metric.human_name
        @element = element
      end

      def inspect
        to_hash.inspect
      end

      def to_hash
        {'metric' => metric_id, 'metric_human_name' => metric_human_name, 'value' => value}.merge!(element.grain)
      end

      def to_axis_values(pivot_axis, flat: true)
        flat ? pivot_axis.flat_grain_value_for(self) : pivot_axis.hash_grain_value_for(self)
      end

      def value
        element.fetch(metric_id)
      end

      def [](key)
        case key.to_s
          when 'metric'
            metric_id
          when 'value'
            value
          else
            element.fetch(key)
        end
      end
    end
  end
end
