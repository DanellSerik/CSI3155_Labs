library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    port (
        CLK                       : in  STD_LOGIC;
        EN                        : in  STD_LOGIC;
        INIT                      : in  STD_LOGIC;
        selLMASK, loadLMASK       : in  STD_LOGIC;
        selRMASK, loadRMASK       : in  STD_LOGIC;
        selDISPLAY1, selDISPLAY2  : in  STD_LOGIC;
        loadDISPLAY               : in  STD_LOGIC;
        DISPLAY_OUT               : out STD_LOGIC_VECTOR(7 downto 0)
    );
end datapath;

architecture structural of datapath is
    signal LMASK_q, RMASK_q, DISPLAY_q  : STD_LOGIC_VECTOR(7 downto 0);
    signal LMASK_shifted, RMASK_shifted : STD_LOGIC_VECTOR(7 downto 0);
    signal LMASK_mux_out, RMASK_mux_out : STD_LOGIC_VECTOR(7 downto 0);
    signal or_mask                      : STD_LOGIC_VECTOR(7 downto 0);
    signal display_mux_out              : STD_LOGIC_VECTOR(7 downto 0);
    signal display_sel                  : STD_LOGIC_VECTOR(1 downto 0);
    constant ONE_LEFT  : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
    constant ONE_RIGHT : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    constant ALL_OFF   : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
begin

    LMASK_shifted <= LMASK_q(6 downto 0) & '0';
    RMASK_shifted <= '0' & RMASK_q(7 downto 1);

    MUX_L: entity work.mux2_8
        port map ( sel => selLMASK, in0 => ONE_LEFT, in1 => LMASK_shifted, y => LMASK_mux_out );

    REG_L: entity work.reg8 generic map ( RESET_VALUE => ONE_LEFT )
        port map ( d => LMASK_mux_out, load => loadLMASK, rst => INIT, en => EN, clk => CLK, q => LMASK_q );

    MUX_R: entity work.mux2_8
        port map ( sel => selRMASK, in0 => ONE_RIGHT, in1 => RMASK_shifted, y => RMASK_mux_out );

    REG_R: entity work.reg8 generic map ( RESET_VALUE => ONE_RIGHT )
        port map ( d => RMASK_mux_out, load => loadRMASK, rst => INIT, en => EN, clk => CLK, q => RMASK_q );

    OR_MASKS: entity work.or8
        port map ( a => LMASK_q, b => RMASK_q, y => or_mask );

    display_sel <= selDISPLAY2 & selDISPLAY1;

    MUX_D: entity work.mux4_8
        port map ( sel => display_sel,
                   in0 => ALL_OFF, in1 => LMASK_q, in2 => or_mask, in3 => RMASK_q,
                   y   => display_mux_out );

    REG_D: entity work.reg8 generic map ( RESET_VALUE => ALL_OFF )
        port map ( d => display_mux_out, load => loadDISPLAY, rst => INIT, en => EN, clk => CLK, q => DISPLAY_q );

    DISPLAY_OUT <= DISPLAY_q;

end structural;