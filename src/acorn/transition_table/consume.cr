module Acorn
  class TransitionTable
    module Consume
      # This method is shared by StaticMachine and RuntimeMachine
      CONSUME_DEFINITION = "def consume(input : String, acc : Accumulator) : Nil
    current_state = 0
    char = nil
    idx = 0
    last_idx = input.size - 1
    token_begin = 0
    while idx <= last_idx
      char ||= input.char_at(idx)
      transitions = $$table[current_state]
      if (next_state = transitions[char]?) || (next_state = transitions[:any]?)
        idx += 1
        char = nil
      elsif next_state = transitions[:epsilon]?
        $$actions[current_state].call(acc, input, token_begin, idx - 1)
        token_begin = idx
      else
        raise UnexpectedInputError.new(char, idx)
      end
      current_state = next_state
    end
    # last token:
    action = $$actions[current_state]?
    if action
      action.call(acc, input, token_begin, idx - 1)
    else
      raise UnexpectedEndError.new(idx)
    end
  end"

      macro define_consume_method(table_id, actions_id)
        {{
          CONSUME_DEFINITION
            .gsub(/\$\$actions/, actions_id)
            .gsub(/\$\$table/, table_id)
            .id
        }}
      end
    end
  end
end
