
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity signed_divider is
    Port (
        GClock       : in STD_LOGIC;
        GReset       : in STD_LOGIC;
        Start        : in STD_LOGIC;
        OperandA     : in STD_LOGIC_VECTOR(3 downto 0);
        OperandB     : in STD_LOGIC_VECTOR(3 downto 0);
        QuotientOut  : out STD_LOGIC_VECTOR(3 downto 0);
        RemainderOut : out STD_LOGIC_VECTOR(3 downto 0);
        Done         : out STD_LOGIC;
        DivideByZero : out STD_LOGIC;
        Overflow     : out STD_LOGIC
    );
end signed_divider;

architecture Structural of signed_divider is

    -- One-hot controller states
    constant IDLE_STATE   : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant CHECK_STATE  : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant UPDATE_STATE : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant DONE_STATE   : STD_LOGIC_VECTOR(3 downto 0) := "1000";

    signal State : STD_LOGIC_VECTOR(3 downto 0);

    -- Datapath registers
    signal R : STD_LOGIC_VECTOR(4 downto 0);
    signal B : STD_LOGIC_VECTOR(4 downto 0);
    signal Count : STD_LOGIC_VECTOR(3 downto 0);

    -- Datapath connections
    signal R_input : STD_LOGIC_VECTOR(4 downto 0);
    signal B_input : STD_LOGIC_VECTOR(4 downto 0);
    signal Count_input : STD_LOGIC_VECTOR(3 downto 0);

    signal A_extended : STD_LOGIC_VECTOR(4 downto 0);
    signal B_extended : STD_LOGIC_VECTOR(4 downto 0);

    signal ArithmeticResult : STD_LOGIC_VECTOR(4 downto 0);
    signal IncrementedCount : STD_LOGIC_VECTOR(3 downto 0);

    signal QuotientExtended : STD_LOGIC_VECTOR(4 downto 0);
    signal CountExtended : STD_LOGIC_VECTOR(4 downto 0);

    -- Controller and register control
    signal LoadR : STD_LOGIC;
    signal LoadB : STD_LOGIC;
    signal LoadCount : STD_LOGIC;
    signal SelectResult : STD_LOGIC;
    signal SelectCount : STD_LOGIC;

    signal SignA : STD_LOGIC;
    signal SignB : STD_LOGIC;
    signal NegativeQ : STD_LOGIC;

    signal AddSubControl : STD_LOGIC;
    signal CanContinue : STD_LOGIC;

    signal ZeroDivisor : STD_LOGIC;
    signal OverflowFlag : STD_LOGIC;

    signal UnusedCarry1 : STD_LOGIC;
    signal UnusedOverflow1 : STD_LOGIC;
    signal UnusedCarry2 : STD_LOGIC;
    signal UnusedOverflow2 : STD_LOGIC;

begin

    --------------------------------------------------
    -- Sign extension of the 4-bit operands
    --------------------------------------------------

    A_extended <= OperandA(3) & OperandA;
    B_extended <= OperandB(3) & OperandB;

    NegativeQ <= SignA xor SignB;

    --------------------------------------------------
    -- Register input selection
    --------------------------------------------------

    R_MUX: entity work.div_mux5
        port map (
            A   => A_extended,
            B   => ArithmeticResult,
            Sel => SelectResult,
            Y   => R_input
        );

    B_input <= B_extended;

    Count_input <= "0000" when SelectCount = '0'
                   else IncrementedCount;

    --------------------------------------------------
    -- Datapath registers
    --------------------------------------------------

    R_REG: entity work.div_reg5
        port map (
            clk   => GClock,
            reset => GReset,
            load  => LoadR,
            D     => R_input,
            Q     => R
        );

    B_REG: entity work.div_reg5
        port map (
            clk   => GClock,
            reset => GReset,
            load  => LoadB,
            D     => B_input,
            Q     => B
        );

    COUNT_REG: entity work.div_reg4
        port map (
            clk   => GClock,
            reset => GReset,
            load  => LoadCount,
            D     => Count_input,
            Q     => Count
        );

    --------------------------------------------------
    -- Arithmetic unit
    --------------------------------------------------

    -- Same operand signs: subtract B
    -- Different operand signs: add B

    AddSubControl <= not NegativeQ;

    ARITHMETIC: entity work.divider_addsub5
        port map (
            A        => R,
            B        => B,
            AddSub   => AddSubControl,
            Result   => ArithmeticResult,
            CarryOut => UnusedCarry1,
            Overflow => UnusedOverflow1
        );

    --------------------------------------------------
    -- Quotient incrementer
    --------------------------------------------------

    INCREMENTER: entity work.div_inc4
        port map (
            A => Count,
            Y => IncrementedCount
        );

    --------------------------------------------------
    -- Check whether another division step is valid
    --------------------------------------------------

    -- A step is valid if the new remainder is zero
    -- or still has the dividend's original sign.

    CanContinue <= '1'
        when ArithmeticResult = "00000"
        else '1'
        when ArithmeticResult(4) = SignA
        else '0';

    --------------------------------------------------
    -- Quotient sign adjustment
    --------------------------------------------------

    CountExtended <= '0' & Count;

    -- If NegativeQ = 0, calculate 0 + Count.
    -- If NegativeQ = 1, calculate 0 - Count.

    QUOTIENT_SIGN: entity work.divider_addsub5
        port map (
            A        => "00000",
            B        => CountExtended,
            AddSub   => NegativeQ,
            Result   => QuotientExtended,
            CarryOut => UnusedCarry2,
            Overflow => UnusedOverflow2
        );

    QuotientOut <= QuotientExtended(3 downto 0);
    RemainderOut <= R(3 downto 0);

    --------------------------------------------------
    -- Register load control
    --------------------------------------------------

    LoadR <= '1' when
        (State = IDLE_STATE and Start = '1') or
        State = UPDATE_STATE
        else '0';

    LoadB <= '1' when
        State = IDLE_STATE and Start = '1'
        else '0';

    LoadCount <= '1' when
        (State = IDLE_STATE and Start = '1') or
        State = UPDATE_STATE
        else '0';

    SelectResult <= '1' when State = UPDATE_STATE
                    else '0';

    SelectCount <= '1' when State = UPDATE_STATE
                   else '0';

    --------------------------------------------------
    -- Store operand signs and error flags
    --------------------------------------------------

    process(GClock, GReset)
    begin
        if GReset = '1' then
            SignA <= '0';
            SignB <= '0';
            ZeroDivisor <= '0';
            OverflowFlag <= '0';

        elsif rising_edge(GClock) then

            if State = IDLE_STATE and Start = '1' then

                SignA <= OperandA(3);
                SignB <= OperandB(3);

                if OperandB = "0000" then
                    ZeroDivisor <= '1';
                else
                    ZeroDivisor <= '0';
                end if;

                if OperandA = "1000" and
                   OperandB = "1111" then
                    OverflowFlag <= '1';
                else
                    OverflowFlag <= '0';
                end if;

            end if;
        end if;
    end process;

    --------------------------------------------------
    -- One-hot FSM controller
    --------------------------------------------------

    process(GClock, GReset)
    begin
        if GReset = '1' then
            State <= IDLE_STATE;

        elsif rising_edge(GClock) then

            case State is

                when IDLE_STATE =>
                    if Start = '1' then
                        State <= CHECK_STATE;
                    else
                        State <= IDLE_STATE;
                    end if;

                when CHECK_STATE =>
                    if ZeroDivisor = '1' or
                       OverflowFlag = '1' then

                        State <= DONE_STATE;

                    elsif CanContinue = '1' then

                        State <= UPDATE_STATE;

                    else
                        State <= DONE_STATE;
                    end if;

                when UPDATE_STATE =>
                    State <= CHECK_STATE;

                when DONE_STATE =>
                    State <= IDLE_STATE;

                when others =>
                    State <= IDLE_STATE;

            end case;

        end if;
    end process;

    --------------------------------------------------
    -- Outputs
    --------------------------------------------------

    Done <= '1' when State = DONE_STATE else '0';

    DivideByZero <= ZeroDivisor;
    Overflow <= OverflowFlag;

end Structural;
