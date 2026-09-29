library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity moving_lights_tb is
end moving_lights_tb;

architecture test of moving_lights_tb is
    signal CLK, INIT, LEFT, RIGHT : STD_LOGIC := '0';
    signal DISPLAY : STD_LOGIC_VECTOR(7 downto 0);
    constant CLK_PERIOD : time := 10 ns;
    constant SIM_DIV     : natural := 10;   -- tick every 4th CLK edge
    constant TICK_PERIOD : natural := SIM_DIV + 1;
begin

    UUT: entity work.moving_lights
        generic map ( DIV_TERMINAL_COUNT => SIM_DIV )
        port map ( CLK => CLK, INIT => INIT, LEFT => LEFT, RIGHT => RIGHT, DISPLAY => DISPLAY );

    CLK_PROC: process
    begin
        CLK <= '0'; wait for CLK_PERIOD / 2;
        CLK <= '1'; wait for CLK_PERIOD / 2;
    end process;

    STIMULUS: process
        procedure advance(n : natural) is
        begin
            for i in 1 to n loop
                wait until rising_edge(CLK);
            end loop;
        end procedure;
    begin
        INIT <= '1'; LEFT <= '0'; RIGHT <= '0';
        advance(1);
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should be defined and blank the instant reset is applied" severity error;

        INIT <= '0'; LEFT <= '1'; RIGHT <= '0';

        advance(SIM_DIV);
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should not have moved after only one tick" severity error;

        advance(TICK_PERIOD);
        assert DISPLAY = "00000001"
            report "FAIL: expected first LEFT step (00000001)" severity error;
        advance(TICK_PERIOD);
        assert DISPLAY = "00000010"
            report "FAIL: expected LEFT pattern to shift (00000010)" severity error;
	

        LEFT <= '0'; RIGHT <= '1';
        advance(TICK_PERIOD);
        advance(TICK_PERIOD);
	LEFT <= '1';
        assert DISPLAY = "10000000"
            report "FAIL: expected first RIGHT step (10000000)" severity error;
        advance(TICK_PERIOD);
        assert DISPLAY = "01000000"
            report "FAIL: expected RIGHT pattern to shift (01000000)" severity error;

        advance(TICK_PERIOD);
        assert DISPLAY = "00100100"
            report "FAIL: expected combined LEFT+RIGHT pattern (00010000)" severity error;

        LEFT <= '0'; RIGHT <= '0';
        advance(TICK_PERIOD);
        advance(TICK_PERIOD);
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should blank when neither button is pressed" severity error;

        report "All checks passed." severity note;
        wait;
    end process;

end test;
