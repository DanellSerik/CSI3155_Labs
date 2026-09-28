library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8-bit 4:1 mux, built structurally from three mux2_8 instances
-- (standard binary mux tree -- used for the DISPLAY mux).
-- sel = "00" -> in0, "01" -> in1, "10" -> in2, "11" -> in3
entity mux4_8 is
    port ( sel                    : in  STD_LOGIC_VECTOR(1 downto 0);
           in0, in1, in2, in3     : in  STD_LOGIC_VECTOR(7 downto 0);
           y                      : out STD_LOGIC_VECTOR(7 downto 0) );
end mux4_8;

architecture structural of mux4_8 is
    signal a, b : STD_LOGIC_VECTOR(7 downto 0);
begin
    MUX_A: entity work.mux2_8 port map ( sel => sel(0), in0 => in0, in1 => in1, y => a );
    MUX_B: entity work.mux2_8 port map ( sel => sel(0), in0 => in2, in1 => in3, y => b );
    MUX_Y: entity work.mux2_8 port map ( sel => sel(1), in0 => a,   in1 => b,   y => y );
end structural;
