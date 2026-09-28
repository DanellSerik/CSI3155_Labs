library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Basic inverter
entity not1 is
    port ( a : in  STD_LOGIC;
           y : out STD_LOGIC );
end not1;

architecture gate of not1 is
begin
    y <= not a;
end gate;
