library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_1 is
    port ( sel      : in  STD_LOGIC;
           in0, in1 : in  STD_LOGIC;
           y        : out STD_LOGIC );
end mux2_1;

architecture structural of mux2_1 is
    signal sel_n, t0, t1 : STD_LOGIC;
begin
    G_NOT:  entity work.not1 port map ( a => sel, y => sel_n );
    G_AND0: entity work.and2 port map ( a => in0, b => sel_n, y => t0 );
    G_AND1: entity work.and2 port map ( a => in1, b => sel,   y => t1 );
    G_OR:   entity work.or2  port map ( a => t0,  b => t1,    y => y );
end structural;