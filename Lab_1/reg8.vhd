library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg8 is
    generic ( RESET_VALUE : STD_LOGIC_VECTOR(7 downto 0) := (others => '0') );
    port ( d                   : in  STD_LOGIC_VECTOR(7 downto 0);
           load, rst, en, clk  : in  STD_LOGIC;
           q                   : out STD_LOGIC_VECTOR(7 downto 0) := RESET_VALUE );
end reg8;

architecture behavioral of reg8 is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= RESET_VALUE;
            elsif en = '1' and load = '1' then
                q <= d;
            end if;
        end if;
    end process;
end behavioral;