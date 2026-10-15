library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Divider_Datapath is
    Port ( GClock       : in  STD_LOGIC;
           GReset       : in  STD_LOGIC;
           OperandA     : in  STD_LOGIC_VECTOR (3 downto 0);
           OperandB     : in  STD_LOGIC_VECTOR (3 downto 0);
           
           -- Control Signals
           loadA        : in  STD_LOGIC;
           loadQ        : in  STD_LOGIC;
           loadM        : in  STD_LOGIC;
           loadC        : in  STD_LOGIC;
           selA_mode    : in  STD_LOGIC_VECTOR (1 downto 0);
           selQ_mode    : in  STD_LOGIC_VECTOR (1 downto 0);
           decC         : in  STD_LOGIC;
           add_sub_ctrl : in  STD_LOGIC;
           set_Q0       : in  STD_LOGIC;
           
           -- Status Signals & Output
           A3           : out STD_LOGIC;
           M3           : out STD_LOGIC;
           zeroC        : out STD_LOGIC;
           rem_zero     : out STD_LOGIC; -- ADDED: Flag for exact zero remainder
           RemainderOut : out STD_LOGIC_VECTOR (3 downto 0);
           QuotientOut  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Divider_Datapath;

architecture Structural of Divider_Datapath is
    signal A_out, MUX_A_out : STD_LOGIC_VECTOR(3 downto 0);
    signal Q_out, MUX_Q_out : STD_LOGIC_VECTOR(3 downto 0);
    signal M_out, MUX_M_out : STD_LOGIC_VECTOR(3 downto 0);
    signal C_out, MUX_C_out : STD_LOGIC_VECTOR(2 downto 0); 
    signal ALU_Sum          : STD_LOGIC_VECTOR(3 downto 0);
    signal sign_ext_A       : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- Sign-extend OperandA for initial remainder
    sign_ext_A <= (others => OperandA(3));

    -- ==========================================
    -- ROUTING MULTIPLEXERS
    -- ==========================================
    MUX_A_out <= sign_ext_A when selA_mode = "00" else
                 (A_out(2 downto 0) & Q_out(3)) when selA_mode = "01" else -- Left Shift
                 ALU_Sum when selA_mode = "10" else
                 A_out;

    MUX_Q_out <= OperandA when selQ_mode = "00" else
                 (Q_out(2 downto 0) & '0') when selQ_mode = "01" else      -- Left Shift
                 (Q_out(3 downto 1) & set_Q0) when selQ_mode = "10" else   -- Update LSB
                 Q_out;

    MUX_M_out <= OperandB;
    
    -- '100' is decimal 4 for the 4-bit division loop
    MUX_C_out <= "100" when loadM = '1' else (C_out - 1);

    -- ==========================================
    -- REGISTERS
    -- ==========================================
    Reg_A: entity work.Reg4 port map (D_in => MUX_A_out, Load => loadA, GClock => GClock, GReset => GReset, Q_out => A_out);
    Reg_Q: entity work.Reg4 port map (D_in => MUX_Q_out, Load => loadQ, GClock => GClock, GReset => GReset, Q_out => Q_out);
    Reg_M: entity work.Reg4 port map (D_in => MUX_M_out, Load => loadM, GClock => GClock, GReset => GReset, Q_out => M_out);
    -- 3-bit Counter Register
    Reg_C: entity work.Reg3 port map (D_in => MUX_C_out, Load => loadC, GClock => GClock, GReset => GReset, Q_out => C_out);

    -- ==========================================
    -- ARITHMETIC UNIT
    -- ==========================================
    ALU4: entity work.adder_subtractor_4bit port map (
        x            => A_out,
        y            => M_out,
        add_sub_ctrl => add_sub_ctrl,
        cin          => add_sub_ctrl, -- Supplies the +1 for 2's complement subtraction
        s            => ALU_Sum,
        cout         => open,
        overflow     => open
    );

    -- ==========================================
    -- OUTPUTS
    -- ==========================================
    A3 <= A_out(3);
    M3 <= M_out(3);
    zeroC <= '1' when C_out = "000" else '0';
    rem_zero <= '1' when A_out = "0000" else '0'; -- ADDED: Evaluates if remainder is exactly zero
    RemainderOut <= A_out;
    QuotientOut <= Q_out;

end Structural;