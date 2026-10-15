library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Divider_Control is
    Port ( GClock       : in  STD_LOGIC;
           GReset       : in  STD_LOGIC;
           INIT         : in  STD_LOGIC;
           A3           : in  STD_LOGIC;
           M3           : in  STD_LOGIC;
           DivSign      : in  STD_LOGIC; 
           zeroC        : in  STD_LOGIC;
           rem_zero     : in  STD_LOGIC; -- Flag from Datapath
           
           loadA        : out STD_LOGIC;
           loadQ        : out STD_LOGIC;
           loadM        : out STD_LOGIC;
           loadC        : out STD_LOGIC;
           selA_mode    : out STD_LOGIC_VECTOR (1 downto 0);
           selQ_mode    : out STD_LOGIC_VECTOR (1 downto 0);
           decC         : out STD_LOGIC;
           add_sub_ctrl : out STD_LOGIC;
           set_Q0       : out STD_LOGIC
    );
end Divider_Control;

architecture Structural of Divider_Control is
    signal y_S0, y_S1, y_S2, y_S3, y_S4 : STD_LOGIC;
    signal D_S0, D_S1, D_S2, D_S3, D_S4 : STD_LOGIC;
    signal signs_match, needs_correction, correction_op : STD_LOGIC;
begin
    -- Logical flags
    signs_match <= not (A3 xor M3);
    
    -- STOPS THE BUG: Only correct if signs differ AND the remainder is not exactly zero
    needs_correction <= (DivSign xor A3) and (not rem_zero);    
    
    correction_op <= DivSign xor M3; 

    -- ==========================================
    -- NEXT STATE LOGIC
    -- ==========================================
    D_S0 <= INIT; 
    D_S1 <= y_S0 or (y_S3 and not zeroC);
    D_S2 <= y_S1;
    D_S3 <= y_S2;
    D_S4 <= y_S3 and zeroC;

    -- ==========================================
    -- STATE FLIP-FLOPS
    -- ==========================================
    FF_S0 : entity work.D_FF port map (D => D_S0, GClock => GClock, GReset => GReset, Q => y_S0);
    FF_S1 : entity work.D_FF port map (D => D_S1, GClock => GClock, GReset => GReset, Q => y_S1);
    FF_S2 : entity work.D_FF port map (D => D_S2, GClock => GClock, GReset => GReset, Q => y_S2);
    FF_S3 : entity work.D_FF port map (D => D_S3, GClock => GClock, GReset => GReset, Q => y_S3);
    FF_S4 : entity work.D_FF port map (D => D_S4, GClock => GClock, GReset => GReset, Q => y_S4);

    -- ==========================================
    -- OUTPUT LOGIC
    -- ==========================================
    loadA <= y_S0 or y_S1 or y_S2 or (y_S4 and needs_correction);
    
    loadQ <= y_S0 or y_S1 or y_S3;
    loadM <= y_S0;
    loadC <= y_S0 or y_S1;
    
    selA_mode <= "00" when y_S0 = '1' else
                 "01" when y_S1 = '1' else
                 "10" when y_S2 = '1' else
                 "10" when y_S4 = '1' else 
                 "11";
                 
    selQ_mode <= "00" when y_S0 = '1' else
                 "01" when y_S1 = '1' else
                 "10" when y_S3 = '1' else
                 "11";

    decC <= y_S1;
    
    add_sub_ctrl <= (y_S2 and signs_match) or (y_S4 and correction_op); 
    
    set_Q0 <= y_S3 and signs_match;

end Structural;