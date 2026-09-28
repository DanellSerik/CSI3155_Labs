library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1-bit D flip-flop with a synchronous reset to a configurable value.
-- This is a REGISTER, so (per the lab's exception) its architecture
-- is behavioral rather than gate-level.
entity dff is
    generic ( RESET_VALUE : STD_LOGIC := '0' );
    port ( d, clk, rst : in  STD_LOGIC;
           q            : out STD_LOGIC := RESET_VALUE );
end dff;

architecture behavioral of dff is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= RESET_VALUE;
	else
                q <= d;
            end if;
        end if;
    end process;
end behavioral;
