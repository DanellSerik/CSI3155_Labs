
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity divider_addsub5 is
    Port (
        A        : in STD_LOGIC_VECTOR(4 downto 0);
        B        : in STD_LOGIC_VECTOR(4 downto 0);
        AddSub   : in STD_LOGIC;
        Result   : out STD_LOGIC_VECTOR(4 downto 0);
        CarryOut : out STD_LOGIC;
        Overflow : out STD_LOGIC
    );
end divider_addsub5;

architecture Structural of divider_addsub5 is

    signal B_modified : STD_LOGIC_VECTOR(4 downto 0);
    signal Carry      : STD_LOGIC_VECTOR(5 downto 0);

begin

    Carry(0) <= AddSub;

    gen_adders: for i in 0 to 4 generate

        B_modified(i) <= B(i) xor AddSub;

        FA: entity work.full_adder
            port map (
                A    => A(i),
                B    => B_modified(i),
                Cin  => Carry(i),
                S    => Result(i),
                Cout => Carry(i+1)
            );

    end generate;

    CarryOut <= Carry(5);
    Overflow <= Carry(4) xor Carry(5);

end Structural;
