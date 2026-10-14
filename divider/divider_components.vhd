
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_reg5 is
    Port (
        clk   : in STD_LOGIC;
        reset : in STD_LOGIC;
        load  : in STD_LOGIC;
        D     : in STD_LOGIC_VECTOR(4 downto 0);
        Q     : out STD_LOGIC_VECTOR(4 downto 0)
    );
end div_reg5;

architecture RTL of div_reg5 is
    signal reg_data : STD_LOGIC_VECTOR(4 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            reg_data <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                reg_data <= D;
            end if;
        end if;
    end process;

    Q <= reg_data;
end RTL;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_reg4 is
    Port (
        clk   : in STD_LOGIC;
        reset : in STD_LOGIC;
        load  : in STD_LOGIC;
        D     : in STD_LOGIC_VECTOR(3 downto 0);
        Q     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end div_reg4;

architecture RTL of div_reg4 is
    signal reg_data : STD_LOGIC_VECTOR(3 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            reg_data <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                reg_data <= D;
            end if;
        end if;
    end process;

    Q <= reg_data;
end RTL;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_mux5 is
    Port (
        A   : in STD_LOGIC_VECTOR(4 downto 0);
        B   : in STD_LOGIC_VECTOR(4 downto 0);
        Sel : in STD_LOGIC;
        Y   : out STD_LOGIC_VECTOR(4 downto 0)
    );
end div_mux5;

architecture Structural of div_mux5 is
begin
    gen_mux: for i in 0 to 4 generate
        Y(i) <= (A(i) and (not Sel)) or
                (B(i) and Sel);
    end generate;
end Structural;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_inc4 is
    Port (
        A : in STD_LOGIC_VECTOR(3 downto 0);
        Y : out STD_LOGIC_VECTOR(3 downto 0)
    );
end div_inc4;

architecture Structural of div_inc4 is
    signal carry : STD_LOGIC_VECTOR(4 downto 0);
begin
    carry(0) <= '1';

    gen_inc: for i in 0 to 3 generate
        Y(i) <= A(i) xor carry(i);
        carry(i+1) <= A(i) and carry(i);
    end generate;
end Structural;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_compare5 is
    Port (
        A  : in STD_LOGIC_VECTOR(4 downto 0);
        B  : in STD_LOGIC_VECTOR(4 downto 0);
        GE : out STD_LOGIC
    );
end div_compare5;

architecture Structural of div_compare5 is
    signal greater : STD_LOGIC_VECTOR(5 downto 0);
    signal equal_bits : STD_LOGIC_VECTOR(5 downto 0);
    signal unsigned_ge : STD_LOGIC;
begin

    greater(0) <= '0';
    equal_bits(0) <= '1';

    gen_compare: for i in 0 to 4 generate
        greater(i+1) <= greater(i) or
                        (equal_bits(i) and A(i) and (not B(i)));

        equal_bits(i+1) <= equal_bits(i) and
                           (A(i) xnor B(i));
    end generate;

    unsigned_ge <= greater(5) or equal_bits(5);

    GE <= (not A(4)) when (A(4) /= B(4))
          else unsigned_ge;

end Structural;
