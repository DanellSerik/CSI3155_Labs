library ieee;
  use ieee.std_logic_1164.all;

entity debouncer is
  port (
    i_raw   : in  STD_LOGIC;
    i_clock : in  STD_LOGIC;
    o_clean : out STD_LOGIC);
end entity;

architecture fsm of debouncer is
  signal int_currentState, int_nextState : std_logic_vector(1 downto 0);

begin
  -- Combinational logic for next state
  int_nextState <= "00" when i_raw = '0' else
                   "01" when int_currentState = "00" else
                   "10";

  -- Sequential logic
  process (i_clock)
  begin
    if i_clock'event and i_clock = '1' then
      int_currentState <= int_nextState;
    end if;
  end process;

  --  Concurrent Signal Assignment
  o_clean <= '1' when int_currentState = "10" else
             '0';

end architecture;
