LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY down_counter IS
    PORT (
        clk        : IN  STD_LOGIC;
        reset     : IN  STD_LOGIC;
        en_1hz     : IN  STD_LOGIC;
        load       : IN  STD_LOGIC; 
        data_in    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        timer_done : OUT STD_LOGIC
    );
END down_counter;

ARCHITECTURE rtl OF down_counter IS
    SIGNAL count : unsigned(3 DOWNTO 0);
BEGIN
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            count <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                count <= unsigned(data_in);
            ELSIF en_1hz = '1' THEN
                IF count > 0 THEN
                    count <= count - 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Combinational flag: HIGH when count reaches 0
    timer_done <= '1' WHEN count = "0000" ELSE '0';
END rtl;