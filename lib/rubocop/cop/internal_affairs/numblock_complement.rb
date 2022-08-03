# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for missing numblock handlers for cops that check blocks.
      #
      # @example
      #
      #   # bad
      #   class BlockRelatedCop < Base
      #     def on_block(node)
      #     end
      #   end
      #
      #   # good
      #   class BlockRelatedCop < Base
      #     def on_block(node)
      #     end
      #
      #     alias on_numblock on_block
      #   end
      #
      #   class BlockRelatedCop < Base
      #     def on_block(node)
      #     end
      #
      #     alias_method :on_numblock, :on_block
      #   end
      #
      #   class BlockRelatedCop < Base
      #     def on_block(node)
      #     end
      #
      #     def on_numblock(node)
      #     end
      #   end
      class NumblockComplement < Base
        MSG = 'Define on_numblock to handle blocks with numbered arguments.'

        def on_def(node)
          return unless block_handler?(node)
          return unless node.parent

          add_offense(node) unless numblock_handler?(node.parent)
        end

        private

        # @!method block_handler?(node)
        def_node_matcher :block_handler?, <<~PATTERN
          (def :on_block (args (arg :node)) ...)
        PATTERN

        # @!method numblock_handler?(node)
        def_node_matcher :numblock_handler?, <<~PATTERN
          {
            `(def :on_numblock (args (arg :node)) ...)
            `(alias (sym :on_numblock) (sym :on_block))
            `(send nil? :alias_method (sym :on_numblock) (sym :on_block))
          }
        PATTERN
      end
    end
  end
end
