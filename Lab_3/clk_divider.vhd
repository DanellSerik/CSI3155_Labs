LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY clk_divider IS
    PORT (
        clk_in    : IN  STD_LOGIC; -- 100 MHz from board
        resetb    : IN  STD_LOGIC; -- Active-low global reset
        clk_1hz   : OUT STD_LOGIC; -- Used by FSM and counters
        clk_100hz : OUT STD_LOGIC  -- Used by the debouncer
    );
END clk_divider;

ARCHITECTURE behavioral OF clk_divider IS
    -- Terminal counts for a 100 MHz system clock (half-periods)[cite: 3]
    CONSTANT MAX_1HZ   : integer := 10; --50000000; 
    CONSTANT MAX_100HZ : integer := 2; --500000;

    -- Internal counters
    SIGNAL count_1hz   : integer range 0 to MAX_1HZ := 0;
    SIGNAL count_100hz : integer range 0 to MAX_100HZ := 0;
    
    -- Internal flip-flops for the output states
    SIGNAL toggle_1hz   : STD_LOGIC := '0';
    SIGNAL toggle_100hz : STD_LOGIC := '0';

BEGIN
    -- 1 Hz Clock Generation
    PROCESS(clk_in, resetb)
    BEGIN
        IF resetb = '0' THEN
            count_1hz  <= 0;
            toggle_1hz <= '0';
        ELSIF rising_edge(clk_in) THEN
            IF count_1hz = MAX_1HZ - 1 THEN
                count_1hz  <= 0;
                toggle_1hz <= NOT toggle_1hz;
            ELSE
                count_1hz <= count_1hz + 1;
            END IF;
        END IF;
    END PROCESS;

    -- 100 Hz Clock Generation
    PROCESS(clk_in, resetb)
    BEGIN
        IF resetb = '0' THEN
            count_100hz  <= 0;
            toggle_100hz <= '0';
        ELSIF rising_edge(clk_in) THEN
            IF count_100hz = MAX_100HZ - 1 THEN
                count_100hz  <= 0;
                toggle_100hz <= NOT toggle_100hz;
            ELSE
                count_100hz <= count_100hz + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Assign the internal flip-flop states to the output ports
    clk_1hz   <= toggle_1hz;
    clk_100hz <= toggle_100hz;

END behavioral;