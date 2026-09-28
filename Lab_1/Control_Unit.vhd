library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Control unit: one-hot Moore FSM, built structurally from gates
-- and dff's. Each state flip-flop now has an explicit synchronous
-- reset (driven by INIT) instead of relying on D0 = INIT alone --
-- this guarantees a clean, fully-defined one-hot state on the very
-- first clock edge after reset, with no undefined start-up value
-- and no chance of two states being set at once.
entity control_unit is
    port (
        CLK, INIT, LEFT, RIGHT   : in  STD_LOGIC;
        selLMASK, loadLMASK      : out STD_LOGIC;
        selRMASK, loadRMASK      : out STD_LOGIC;
        selDISPLAY1, selDISPLAY2 : out STD_LOGIC;
        loadDISPLAY              : out STD_LOGIC
    );
end control_unit;

architecture structural of control_unit is
    signal S0, S1, S2, S3, S4 : STD_LOGIC;
    signal LEFT_n, RIGHT_n    : STD_LOGIC;
    signal t_LR, t_LRn        : STD_LOGIC;   -- D-inputs for S1, S2
    signal t_LnR, t_LnRn      : STD_LOGIC;   -- D-inputs for S3, S4
    signal load_a, load_c     : STD_LOGIC;   -- loadLMASK/loadRMASK OR chains
    signal ld_a, ld_b, ld_c   : STD_LOGIC;   -- loadDISPLAY OR chain
    constant GND : STD_LOGIC := '0';         -- S0 has no "return" path; it's
                                              -- only ever entered via reset
begin

    ---------------------------------------------------------------
    -- Inverters for LEFT', RIGHT'
    ---------------------------------------------------------------
    N_LEFT:  entity work.not1 port map ( a => LEFT,  y => LEFT_n );
    N_RIGHT: entity work.not1 port map ( a => RIGHT, y => RIGHT_n );

    ---------------------------------------------------------------
    -- Next-state AND gates (D inputs of the S1..S4 flip-flops)
    ---------------------------------------------------------------
    A_S1: entity work.and2 port map ( a => LEFT,   b => RIGHT,   y => t_LR );
    A_S2: entity work.and2 port map ( a => LEFT,   b => RIGHT_n, y => t_LRn );
    A_S3: entity work.and2 port map ( a => LEFT_n, b => RIGHT,   y => t_LnR );
    A_S4: entity work.and2 port map ( a => LEFT_n, b => RIGHT_n, y => t_LnRn );

    ---------------------------------------------------------------
    -- State register: one D flip-flop per state bit (one-hot).
    -- rst => INIT on every flip-flop; S0 resets to '1', S1..S4
    -- reset to '0', so reset always lands cleanly on S0 alone.
    ---------------------------------------------------------------
    FF_S0: entity work.dff generic map ( RESET_VALUE => '1' )
                            port map ( d => GND,    rst => INIT, clk => CLK, q => S0 );
    FF_S1: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LR,   rst => INIT, clk => CLK, q => S1 );
    FF_S2: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LRn,  rst => INIT, clk => CLK, q => S2 );
    FF_S3: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LnR,  rst => INIT, clk => CLK, q => S3 );
    FF_S4: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LnRn, rst => INIT, clk => CLK, q => S4 );

    ---------------------------------------------------------------
    -- Output logic (Moore) -- matches the gate-level control path
    ---------------------------------------------------------------
    OR_selL:    entity work.or2 port map ( a => S1,     b => S2, y => selLMASK );
    OR_loadL_a: entity work.or2 port map ( a => S0,     b => S1, y => load_a );
    OR_loadL_b: entity work.or2 port map ( a => load_a, b => S2, y => loadLMASK );

    OR_selR:    entity work.or2 port map ( a => S1,     b => S3, y => selRMASK );
    OR_loadR_a: entity work.or2 port map ( a => S0,     b => S1, y => load_c );
    OR_loadR_b: entity work.or2 port map ( a => load_c, b => S3, y => loadRMASK );

    OR_d1: entity work.or2 port map ( a => S2, b => S3, y => selDISPLAY1 );
    OR_d2: entity work.or2 port map ( a => S1, b => S3, y => selDISPLAY2 );

    OR_ld_a: entity work.or2 port map ( a => S0,   b => S1, y => ld_a );
    OR_ld_b: entity work.or2 port map ( a => ld_a, b => S2, y => ld_b );
    OR_ld_c: entity work.or2 port map ( a => ld_b, b => S3, y => ld_c );
    OR_ld_d: entity work.or2 port map ( a => ld_c, b => S4, y => loadDISPLAY );

end structural;