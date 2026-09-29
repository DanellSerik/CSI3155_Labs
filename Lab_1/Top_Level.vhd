library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity moving_lights is
    generic ( DIV_TERMINAL_COUNT : natural := 99_999_999 );
    port (
        CLK, INIT, LEFT, RIGHT : in  STD_LOGIC;
        DISPLAY                : out STD_LOGIC_VECTOR(7 downto 0)
    );
end moving_lights;

architecture structural of moving_lights is
    signal selLMASK, loadLMASK : STD_LOGIC;
    signal selRMASK, loadRMASK : STD_LOGIC;
    signal selDISPLAY1         : STD_LOGIC;
    signal selDISPLAY2         : STD_LOGIC;
    signal loadDISPLAY         : STD_LOGIC;
    signal EN                  : STD_LOGIC;
begin

    DIV: entity work.clock_divider
        generic map ( WIDTH => 27, TERMINAL_COUNT => DIV_TERMINAL_COUNT )
        port map ( CLK => CLK, RST => INIT, TICK => EN );

    CU: entity work.control_unit
        port map (
            CLK => CLK, EN => EN, INIT => INIT, LEFT => LEFT, RIGHT => RIGHT,
            selLMASK => selLMASK, loadLMASK => loadLMASK,
            selRMASK => selRMASK, loadRMASK => loadRMASK,
            selDISPLAY1 => selDISPLAY1, selDISPLAY2 => selDISPLAY2,
            loadDISPLAY => loadDISPLAY
        );

    DP: entity work.datapath
        port map (
            CLK => CLK, EN => EN, INIT => INIT,
            selLMASK => selLMASK, loadLMASK => loadLMASK,
            selRMASK => selRMASK, loadRMASK => loadRMASK,
            selDISPLAY1 => selDISPLAY1, selDISPLAY2 => selDISPLAY2,
            loadDISPLAY => loadDISPLAY,
            DISPLAY_OUT => DISPLAY
        );

end structural;