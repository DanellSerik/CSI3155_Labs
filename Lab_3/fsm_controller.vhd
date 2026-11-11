LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY simplified_fsm IS
    PORT (
        clk        : IN  STD_LOGIC;
        resetb     : IN  STD_LOGIC;
        timer_done : IN  STD_LOGIC; -- 'T' variable
        SSCS       : IN  STD_LOGIC; -- 'S' variable
        MSTL       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SSTL       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        next_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Feeds the MUX
        load_timer : OUT STD_LOGIC                     -- Feeds the Counter
    );
END simplified_fsm;

ARCHITECTURE structural OF simplified_fsm IS
    COMPONENT d_ff
        PORT (
            clk    : IN  STD_LOGIC;
            resetb : IN  STD_LOGIC;
            d      : IN  STD_LOGIC;
            q      : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL y1, y0 : STD_LOGIC; 
    SIGNAL d1, d0 : STD_LOGIC; 
BEGIN
    -- State memory
    FF1: d_ff PORT MAP (clk => clk, resetb => resetb, d => d1, q => y1);
    FF0: d_ff PORT MAP (clk => clk, resetb => resetb, d => d0, q => y0);

    -- Combinational Logic: Simplified Excitation Equations
    -- d1 = (y0 * T) + (y1 * y0) + (y1 * NOT T)
    d1 <= (y0 AND timer_done) OR (y1 AND y0) OR (y1 AND NOT timer_done);
    
    -- d0 = (NOT y1 * y0) + (NOT y1 * T * S) + (y0 * NOT T)
    d0 <= (NOT y1 AND y0) OR (NOT y1 AND timer_done AND SSCS) OR (y0 AND NOT timer_done);

    -- Output the next state directly to the MUX select line
    next_state(1) <= d1;
    next_state(0) <= d0;

    -- Load Timer Flag: HIGH when transitioning states
    -- Fires if (In S0 and T and S) OR (Not in S0 and T)
    load_timer <= timer_done AND (SSCS OR y1 OR y0);

    -- Traffic Light Outputs (Unchanged Moore Logic)
    MSTL(2) <= y1;
    MSTL(1) <= NOT y1 AND y0;
    MSTL(0) <= NOT y1 AND NOT y0;

    SSTL(2) <= NOT y1;
    SSTL(1) <= y1 AND NOT y0;
    SSTL(0) <= y1 AND y0;

END structural;