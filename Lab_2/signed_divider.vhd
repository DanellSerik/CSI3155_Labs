library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Signed_Divider is
    Port ( GClock    : in  STD_LOGIC;
           GReset    : in  STD_LOGIC;
           Start     : in  STD_LOGIC; 
           OperandA  : in  STD_LOGIC_VECTOR (3 downto 0);
           OperandB  : in  STD_LOGIC_VECTOR (3 downto 0);
           Quotient  : out STD_LOGIC_VECTOR (3 downto 0);
           Remainder : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Signed_Divider;

architecture Structural of Signed_Divider is
    signal A3, M3, zeroC, rem_zero : STD_LOGIC;
    signal loadA, loadQ, loadM, loadC : STD_LOGIC;
    signal selA_mode, selQ_mode : STD_LOGIC_VECTOR(1 downto 0);
    signal decC, add_sub_ctrl, set_Q0 : STD_LOGIC;
begin

    ControlUnit: entity work.Divider_Control port map (
        GClock       => GClock,
        GReset       => GReset,
        INIT         => Start,
        A3           => A3,
        M3           => M3,
        DivSign      => OperandA(3), -- Passes original dividend sign
        zeroC        => zeroC,
        rem_zero     => rem_zero,   
        loadA        => loadA,
        loadQ        => loadQ,
        loadM        => loadM,
        loadC        => loadC,
        selA_mode    => selA_mode,
        selQ_mode    => selQ_mode,
        decC         => decC,
        add_sub_ctrl => add_sub_ctrl,
        set_Q0       => set_Q0
    );

    DataUnit: entity work.Divider_Datapath port map (
        GClock       => GClock,
        GReset       => GReset,
        OperandA     => OperandA,
        OperandB     => OperandB,
        loadA        => loadA,
        loadQ        => loadQ,
        loadM        => loadM,
        loadC        => loadC,
        selA_mode    => selA_mode,
        selQ_mode    => selQ_mode,
        decC         => decC,
        add_sub_ctrl => add_sub_ctrl,
        set_Q0       => set_Q0,
        A3           => A3,
        M3           => M3,
        zeroC        => zeroC,
        rem_zero     => rem_zero,   --So it doesn't check the sign missmatch when r=0
        RemainderOut => Remainder,
        QuotientOut  => Quotient
    );

end Structural;