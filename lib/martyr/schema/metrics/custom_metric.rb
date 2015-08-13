module Martyr
  module Schema
    class CustomMetric < BaseMetric

      attr_accessor :block

      def build_slice(**slice_definition)
        raise Runtime::Error.new("Custom metrics cannot be sliced: attempted on metric `#{name}`")
      end

      # @param scopeable [#update_scope]
      def apply_on_data(scopeable)
        # no-op
      end

    end
  end
end