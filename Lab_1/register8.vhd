library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8-bit register with load enable (LMASK/RMASK/DISPLAY registers).
-- This is a REGISTER, so its architecture is behavioral.
entity reg8 is
    port ( d         : in  STD_LOGIC_VECTOR(7 downto 0);
           load, clk : in  STD_LOGIC;
           q         : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0') );
end reg8;

architecture behavioral of reg8 is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                q <= d;
            end if;
        end if;
    end process;
end behavioral;
