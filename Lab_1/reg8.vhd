library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8-bit register with load enable AND a synchronous reset to a
-- configurable value. This is a REGISTER, so its architecture is
-- behavioral. rst takes priority over load.
entity reg8 is
    generic ( RESET_VALUE : STD_LOGIC_VECTOR(7 downto 0) := (others => '0') );
    port ( d              : in  STD_LOGIC_VECTOR(7 downto 0);
           load, rst, clk : in  STD_LOGIC;
           q              : out STD_LOGIC_VECTOR(7 downto 0) := RESET_VALUE );
end reg8;

architecture behavioral of reg8 is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= RESET_VALUE;
            elsif load = '1' then
                q <= d;
            end if;
        end if;
    end process;
end behavioral;