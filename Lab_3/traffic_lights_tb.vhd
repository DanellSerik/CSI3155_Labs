LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY traffic_lights_tb IS
-- Testbench has no ports
END traffic_lights_tb;

ARCHITECTURE behavior OF traffic_lights_tb IS

    -- Signals to connect to the DUT (Device Under Test)
    SIGNAL GClock : STD_LOGIC := '0';
    SIGNAL GReset : STD_LOGIC := '1';
    SIGNAL MSC    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100"; -- Set Main Green to 4 ticks
    SIGNAL SSC    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010"; -- Set Side Green to 2 ticks
    SIGNAL SSCS   : STD_LOGIC := '0';
    
    SIGNAL MSTL   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SSTL   : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- 100 MHz Clock period
    CONSTANT clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Top-Level Module
    DUT: entity work.traffic_light_top
        PORT MAP (
            GClock => GClock,
            GReset => GReset,
            MSC    => MSC,
            SSC    => SSC,
            SSCS   => SSCS,
            MSTL   => MSTL,
            SSTL   => SSTL
        );

    -- Clock Generation Process
    clk_process: PROCESS
    BEGIN
        GClock <= '0';
        WAIT FOR clk_period/2;
        GClock <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus Process to test intersection scenarios
    stim_proc: PROCESS
    BEGIN
        -- 0. Power-on Reset
        GReset <= '0';
        WAIT FOR 100 ns;
        GReset <= '1';
        
        -- Wait for FSM to settle into S0 (Main Green)
        WAIT FOR 100 ns;

        -- SCENARIO 1: Main street green, no car on side street.
        -- Wait longer than the MSC timer (4 ticks) to prove the light stays green.
        -- Assuming you scaled MAX_1HZ to 10 clock cycles for simulation:
        WAIT FOR 1500 ns; 
        
        -- SCENARIO 2: Car arrives AFTER MSC has expired.
        -- The light should immediately transition to Main Yellow.
        SSCS <= '1';
        WAIT FOR 500 ns; -- Hold button long enough for debouncer to register
        SSCS <= '0';     -- Car passes through
        
        -- Wait for the full side-street cycle to finish (MT -> SSC -> SST -> S0)
        WAIT FOR 4000 ns;

        -- SCENARIO 3: Car arrives BEFORE MSC expires.
        -- Reset the system to restart the MSC timer.
        GReset <= '0';
        WAIT FOR 100 ns;
        GReset <= '1';
        
        WAIT FOR 100 ns; -- Wait just 1 tick (MSC is not finished)
        SSCS <= '1';     -- Car arrives early
        
        -- Observe waveform: MSTL must remain Green until MSC finishes counting down,
        -- only THEN should it switch to Yellow.
        WAIT FOR 2000 ns; 
        SSCS <= '0';

        -- Suspend simulation
        WAIT;
    END PROCESS;

END behavior;