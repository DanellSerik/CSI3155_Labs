library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    port (
        CLK, EN, INIT, LEFT, RIGHT : in  STD_LOGIC;
        selLMASK, loadLMASK      : out STD_LOGIC;
        selRMASK, loadRMASK      : out STD_LOGIC;
        selDISPLAY1, selDISPLAY2 : out STD_LOGIC;
        loadDISPLAY              : out STD_LOGIC
    );
end control_unit;

architecture structural of control_unit is
    signal S0, S1, S2, S3, S4 : STD_LOGIC;
    signal LEFT_n, RIGHT_n    : STD_LOGIC;
    signal t_LR, t_LRn        : STD_LOGIC;   
    signal t_LnR, t_LnRn      : STD_LOGIC;   
    signal load_a, load_c     : STD_LOGIC;   
    signal ld_a, ld_b, ld_c   : STD_LOGIC;   
    constant GND : STD_LOGIC := '0';         
                                              
begin


    N_LEFT:  entity work.not1 port map ( a => LEFT,  y => LEFT_n );
    N_RIGHT: entity work.not1 port map ( a => RIGHT, y => RIGHT_n );

    A_S1: entity work.and2 port map ( a => LEFT,   b => RIGHT,   y => t_LR );
    A_S2: entity work.and2 port map ( a => LEFT,   b => RIGHT_n, y => t_LRn );
    A_S3: entity work.and2 port map ( a => LEFT_n, b => RIGHT,   y => t_LnR );
    A_S4: entity work.and2 port map ( a => LEFT_n, b => RIGHT_n, y => t_LnRn );


    FF_S0: entity work.dff generic map ( RESET_VALUE => '1' )
                            port map ( d => GND,    rst => INIT, clk => CLK, en => EN, q => S0 );
    FF_S1: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LR,   rst => INIT, clk => CLK, en => EN, q => S1 );
    FF_S2: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LRn,  rst => INIT, clk => CLK, en => EN, q => S2 );
    FF_S3: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LnR,  rst => INIT, clk => CLK, en => EN, q => S3 );
    FF_S4: entity work.dff generic map ( RESET_VALUE => '0' )
                            port map ( d => t_LnRn, rst => INIT, clk => CLK, en => EN, q => S4 );

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