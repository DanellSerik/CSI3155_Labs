LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY traffic_light_top IS
    PORT (
        GClock : IN  STD_LOGIC;
        GReset : IN  STD_LOGIC;
        MSC    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        SSC    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        SSCS   : IN  STD_LOGIC;
        MSTL   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SSTL   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END traffic_light_top;

ARCHITECTURE structural OF traffic_light_top IS

    -- Internal wires. Using entity work instantiations, so no COMPONENT declarations are needed.
    SIGNAL en_1hz_sig      : STD_LOGIC;
    SIGNAL en_100hz_sig    : STD_LOGIC; -- Added 100 Hz clock for the new debouncer
    SIGNAL sscs_clean      : STD_LOGIC;
    SIGNAL timer_done_sig  : STD_LOGIC;
    SIGNAL load_timer_sig  : STD_LOGIC;
    SIGNAL next_state_sig  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL timer_val_sig   : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    -- 1. Clock Divider (Must be updated to output both 1 Hz and 100 Hz)
    U_CLK_DIV: entity work.clk_divider 
        PORT MAP (
            clk_in    => GClock,
            resetb    => GReset,
            clk_1hz   => en_1hz_sig,
            clk_100hz => en_100hz_sig -- Routing the new 100 Hz signal
        );

    -- 2. Button Debouncer for Car Sensor (Updated to match provided VHDL)
    U_DEBOUNCER: entity work.debouncer 
        PORT MAP (
            i_clock => en_100hz_sig,  -- Debouncer is sampled at 100 Hz
            i_raw   => SSCS,          -- Raw button input
            o_clean => sscs_clean     -- Cleaned signal to FSM
        );

    -- 3. The 4-to-1 Multiplexer
    U_MUX: entity work.timer_mux 
        PORT MAP (
            next_state => next_state_sig,
            MSC_MAX    => MSC,
            SSC_MAX    => SSC,
            timer_val  => timer_val_sig
        );

    -- 4. The Shared Counter
    U_COUNTER: entity work.down_counter 
        PORT MAP (
            clk        => GClock,
            reset      => GReset,
            en_1hz     => en_1hz_sig,
            load       => load_timer_sig,
            data_in    => timer_val_sig,
            timer_done => timer_done_sig
        );

    -- 5. The Simplified FSM Controller
    U_FSM: entity work.simplified_fsm 
        PORT MAP (
            clk        => GClock,
            resetb     => GReset,
            timer_done => timer_done_sig,
            SSCS       => sscs_clean,
            MSTL       => MSTL,
            SSTL       => SSTL,
            next_state => next_state_sig,
            load_timer => load_timer_sig
        );

END structural;