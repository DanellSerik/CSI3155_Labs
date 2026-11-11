LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY timer_mux IS
    PORT (
        next_state : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); -- Driven by D1 and D0 from FSM
        MSC_MAX    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        SSC_MAX    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        timer_val  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END timer_mux;

ARCHITECTURE dataflow OF timer_mux IS
BEGIN
    WITH next_state SELECT
        timer_val <= 
            MSC_MAX WHEN "00",  -- Next state is S0 (Main Green)
            "0011"  WHEN "01",  -- Next state is S1 (Main Yellow, 3 seconds)
            SSC_MAX WHEN "11",  -- Next state is S2 (Side Green)
            "0011"  WHEN "10",  -- Next state is S3 (Side Yellow, 3 seconds)
            "0000"  WHEN OTHERS;
END dataflow;