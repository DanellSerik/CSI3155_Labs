
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Control unit: one-hot Moore FSM (S0..S4) implementing the ASM chart.
entity control_unit is
    port (
        CLK, INIT, LEFT, RIGHT   : in  STD_LOGIC;
        selLMASK, loadLMASK      : out STD_LOGIC;
        selRMASK, loadRMASK      : out STD_LOGIC;
        selDISPLAY1, selDISPLAY2 : out STD_LOGIC;
        loadDISPLAY              : out STD_LOGIC
    );
end control_unit;

architecture behavioral of control_unit is
    type state_type is (S0, S1, S2, S3, S4);
    signal current_state, next_state : state_type;
begin

    ----------------------------------------------------------------
    -- State register (INIT is an asynchronous reset to S0, matching
    -- the "INIT" input feeding the S0 flip-flop directly)
    ----------------------------------------------------------------
    process (CLK, INIT)
    begin
        if INIT = '1' then
            current_state <= S0;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Next-state logic, straight from the ASM chart:
    -- S0 branches on LEFT/RIGHT; S1..S4 all return to S0.
    ----------------------------------------------------------------
    process (current_state, LEFT, RIGHT)
    begin
        case current_state is
            when S0 =>
                if LEFT = '1' and RIGHT = '1' then
                    next_state <= S1;
                elsif LEFT = '1' and RIGHT = '0' then
                    next_state <= S2;
                elsif LEFT = '0' and RIGHT = '1' then
                    next_state <= S3;
                else
                    next_state <= S4;
                end if;
            when others =>              -- S1, S2, S3, S4
                next_state <= S0;
        end case;
    end process;

    ----------------------------------------------------------------
    -- Output logic (Moore) -- matches the gate-level control path:
    --   selLMASK    = S1 + S2
    --   loadLMASK   = S0 + S1 + S2
    --   selRMASK    = S1 + S3
    --   loadRMASK   = S0 + S1 + S3
    --   selDISPLAY1 = S2 + S3
    --   selDISPLAY2 = S1 + S3
    --   loadDISPLAY = S0 + S1 + S2 + S3 + S4  (always 1)
    ----------------------------------------------------------------
    selLMASK    <= '1' when (current_state = S1 or current_state = S2) else '0';
    loadLMASK   <= '1' when (current_state = S0 or current_state = S1 or current_state = S2) else '0';
    selRMASK    <= '1' when (current_state = S1 or current_state = S3) else '0';
    loadRMASK   <= '1' when (current_state = S0 or current_state = S1 or current_state = S3) else '0';
    selDISPLAY1 <= '1' when (current_state = S2 or current_state = S3) else '0';
    selDISPLAY2 <= '1' when (current_state = S1 or current_state = S3) else '0';
    loadDISPLAY <= '1';

end behavioral;