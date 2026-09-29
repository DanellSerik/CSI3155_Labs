library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dff is
    generic ( RESET_VALUE : STD_LOGIC := '0' );
    port ( d, clk, rst, en : in  STD_LOGIC;
           q                : out STD_LOGIC := RESET_VALUE );
end dff;

architecture behavioral of dff is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= RESET_VALUE;
            elsif en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end behavioral;
