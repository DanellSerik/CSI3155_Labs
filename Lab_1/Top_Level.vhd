
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top level: connects control_unit and datapath.
entity moving_lights is
    port (
        CLK, INIT, LEFT, RIGHT : in  STD_LOGIC;
        DISPLAY                : out STD_LOGIC_VECTOR(7 downto 0)
    );
end moving_lights;

architecture structural of moving_lights is
    signal selLMASK, loadLMASK   : STD_LOGIC;
    signal selRMASK, loadRMASK   : STD_LOGIC;
    signal selDISPLAY1           : STD_LOGIC;
    signal selDISPLAY2           : STD_LOGIC;
    signal loadDISPLAY           : STD_LOGIC;
begin

    CU: entity work.Control_Unit
        port map (
            CLK         => CLK,
            INIT        => INIT,
            LEFT        => LEFT,
            RIGHT       => RIGHT,
            selLMASK    => selLMASK,
            loadLMASK   => loadLMASK,
            selRMASK    => selRMASK,
            loadRMASK   => loadRMASK,
            selDISPLAY1 => selDISPLAY1,
            selDISPLAY2 => selDISPLAY2,
            loadDISPLAY => loadDISPLAY
        );

    DP: entity work.Datapath
        port map (
            CLK         => CLK,
            selLMASK    => selLMASK,
            loadLMASK   => loadLMASK,
            selRMASK    => selRMASK,
            loadRMASK   => loadRMASK,
            selDISPLAY1 => selDISPLAY1,
            selDISPLAY2 => selDISPLAY2,
            loadDISPLAY => loadDISPLAY,
            DISPLAY_OUT => DISPLAY
        );

end structural;