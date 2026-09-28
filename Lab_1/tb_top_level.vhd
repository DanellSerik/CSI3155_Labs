library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Self-checking testbench for moving_lights.
-- Exercises reset, LEFT-only, RIGHT-only, LEFT+RIGHT, and neither,
-- and asserts DISPLAY against hand-traced expected values.
entity moving_lights_tb is
end moving_lights_tb;

architecture test of moving_lights_tb is
    signal CLK, INIT, LEFT, RIGHT : STD_LOGIC := '0';
    signal DISPLAY : STD_LOGIC_VECTOR(7 downto 0);
    constant CLK_PERIOD : time := 20 ns;
begin

    UUT: entity work.moving_lights
        port map ( CLK => CLK, INIT => INIT, LEFT => LEFT, RIGHT => RIGHT, DISPLAY => DISPLAY );

    CLK_PROC: process
    begin
        CLK <= '0'; wait for CLK_PERIOD / 2;
        CLK <= '1'; wait for CLK_PERIOD / 2;
    end process;

    STIMULUS: process
    begin
        -- Edge 1: pulse INIT with both buttons released -- releasing
        -- LEFT/RIGHT during INIT avoids a race where a button pressed
        -- at the same instant as reset can leak into a mask register.
        INIT <= '1'; LEFT <= '0'; RIGHT <= '0';
        wait until rising_edge(CLK);

        -- Edge 2: release INIT, let LMASK/RMASK settle to their reset values
        INIT <= '0';
        wait until rising_edge(CLK);
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should be blank right after reset" severity error;

        -- Hold LEFT only: a single lit LED should walk left, one step per cycle
        LEFT <= '1'; RIGHT <= '0';
        wait until rising_edge(CLK);   -- edge 3
        wait until rising_edge(CLK); wait for 1 ns;  -- edge 4
        assert DISPLAY = "00000001"
            report "FAIL: expected first LEFT step (00000001)" severity error;

        -- Switch to RIGHT only: a single lit LED should walk in from the right
        LEFT <= '0'; RIGHT <= '1';
        wait until rising_edge(CLK);   -- edge 6
        wait until rising_edge(CLK); wait for 1 ns;   -- edge 7
        assert DISPLAY = "10000000"
            report "FAIL: expected first RIGHT step (10000000)" severity error;

        -- Hold both buttons: LMASK and RMASK should combine (OR) on DISPLAY
        LEFT <= '1'; RIGHT <= '1';
        wait until rising_edge(CLK);   -- edge 9
        wait until rising_edge(CLK); wait for 1 ns;  -- edge 10
        assert DISPLAY = "10000001"
            report "FAIL: expected combined LEFT+RIGHT pattern (00011000)" severity error;

        -- Release both buttons: display should blank
        LEFT <= '0'; RIGHT <= '0';
        wait until rising_edge(CLK);   -- edge 11
        wait until rising_edge(CLK);   -- edge 12
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should blank when neither button is pressed" severity error;

	LEFT <= '1'; RIGHT <= '0';
        wait until rising_edge(CLK);   -- edge 3
        wait until rising_edge(CLK); wait for 1 ns;  -- edge 4
        assert DISPLAY = "00000010"
            report "FAIL: expected first LEFT step (00000010)" severity error;

        -- Switch to RIGHT only: a single lit LED should walk in from the right
        LEFT <= '0'; RIGHT <= '1';
        wait until rising_edge(CLK);   -- edge 6
        wait until rising_edge(CLK); wait for 1 ns;   -- edge 7
        assert DISPLAY = "10000000"
            report "FAIL: expected first RIGHT step (01000000)" severity error;

        -- Hold both buttons: LMASK and RMASK should combine (OR) on DISPLAY
        LEFT <= '1'; RIGHT <= '1';
        wait until rising_edge(CLK);   -- edge 9
        wait until rising_edge(CLK); wait for 1 ns;  -- edge 10
        assert DISPLAY = "10000001"
            report "FAIL: expected combined LEFT+RIGHT pattern (01000010)" severity error;

        -- Release both buttons: display should blank
        LEFT <= '0'; RIGHT <= '0';
        wait until rising_edge(CLK);   -- edge 11
        wait until rising_edge(CLK);   -- edge 12
        assert DISPLAY = "00000000"
            report "FAIL: DISPLAY should blank when neither button is pressed" severity error;

        report "All checks passed." severity note;
        wait;
    end process;

end test;
