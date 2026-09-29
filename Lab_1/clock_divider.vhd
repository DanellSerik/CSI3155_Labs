library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    generic ( WIDTH          : natural := 27;
              TERMINAL_COUNT : natural := 1 );
    port ( CLK, RST : in  STD_LOGIC;
           TICK      : out STD_LOGIC );
end clock_divider;

architecture behavioral of clock_divider is
    signal count : UNSIGNED(WIDTH-1 downto 0) := (others => '0');
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' or count = TERMINAL_COUNT then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    TICK <= '1' when count = TERMINAL_COUNT else '0';

end behavioral;
