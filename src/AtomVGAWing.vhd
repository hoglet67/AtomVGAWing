library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity AtomVGAWing is
    Port (
        clock32 : in  std_logic;
        rst     : in  std_logic;
        red     : out std_logic_vector (2 downto 0);
        green   : out std_logic_vector (2 downto 0);
        blue    : out std_logic_vector (1 downto 0);
        hsync   : out std_logic;
        vsync   : out std_logic;
        clamp   : out std_logic;

        led     : out std_logic_vector (4 downto 1);
              
        test    : out std_logic_vector (6 downto 1);

        switch  : in  std_logic_vector (8 downto 1);
        unused  : in  std_logic;
              
        AL_P    : in  std_logic;
        AL_N    : in  std_logic;
        AH_P    : in  std_logic;
        AH_N    : in  std_logic;
        BL_P    : in  std_logic;
        BL_N    : in  std_logic;
        BH_P    : in  std_logic;
        BH_N    : in  std_logic;
        LUM_P   : in  std_logic;
        LUM_N   : in  std_logic;
        HS_N    : in  std_logic;
        FS_N    : in  std_logic
    );
end;

architecture Behavioral of AtomVGAWing is

    constant atomClampStart : unsigned(10 downto 0) := to_unsigned(2048 - 59 * 4 - 110, 11);
    constant atomClampEnd   : unsigned(10 downto 0) := to_unsigned(2048 - 59 * 4 - 10, 11);
    constant atomhInit      : unsigned(10 downto 0) := to_unsigned(2048 - 370, 11);
    constant atomvInit      : unsigned(8 downto 0)  := to_unsigned(512 - 39, 9);
    constant atomhBorder    : unsigned(10 downto 0) := to_unsigned(2048 - 16 + 3, 11);
    constant atomvBorder    : unsigned(8 downto 0)  := to_unsigned(512 - 25, 11);

    signal atomhCounter : unsigned(10 downto 0) := (others => '0');
    signal atomvCounter : unsigned(8 downto 0)  := (others => '0');
    
    signal AL0: std_logic;
    signal AL1: std_logic;
    signal AL2: std_logic;
    signal AL3: std_logic;
    signal AL4: std_logic;
    signal AL5: std_logic;
    
    signal AH0: std_logic;
    signal AH1: std_logic;
    signal AH2: std_logic;
    signal AH3: std_logic;
    signal AH4: std_logic;
    signal AH5: std_logic;
    
    signal BL0: std_logic;
    signal BL1: std_logic;
    signal BL2: std_logic;
    signal BL3: std_logic;
    signal BL4: std_logic;
    signal BL5: std_logic;
    
    signal BH0: std_logic;
    signal BH1: std_logic;
    signal BH2: std_logic;
    signal BH3: std_logic;
    signal BH4: std_logic;
    signal BH5: std_logic;
    
    signal L0: std_logic;
    signal L1: std_logic;
    signal L2: std_logic;
    signal L3: std_logic;
    signal L4: std_logic;
    signal L5: std_logic;

    signal AL: std_logic;
    signal AH: std_logic;
    signal BL: std_logic;
    signal BH: std_logic;
    signal L:  std_logic;
    signal R:  std_logic;
    signal G1: std_logic;
    signal G2: std_logic;
    signal B:  std_logic;
    
    signal atomhSync0: std_logic := '0';
    signal atomhSync1: std_logic := '0';
    signal atomhSync2: std_logic := '0';
    signal atomhSync3: std_logic := '0';
    signal atomhSync4: std_logic := '0';
    signal atomhSync5: std_logic := '0';
    
    signal atomvSync0: std_logic := '0';
    signal atomvSync1: std_logic := '0';
    signal atomvSync2: std_logic := '0';
    signal atomvSync3: std_logic := '0';
    signal atomvSync4: std_logic := '0';
    signal atomvSync5: std_logic := '0';
    
    signal atomhSync: std_logic := '0';
    signal atomvSync: std_logic := '0';

    signal atomvSyncToggle: std_logic := '0';
    signal atomhSyncToggle: std_logic := '0';

    signal clock32out  : std_logic;
    signal pixelClock  : std_logic;
    signal atomClock   : std_logic;
    signal tmpClock    : std_logic;
    signal tmpVgaClock : std_logic;

    signal lockeda1    : std_logic;
    signal lockeda2    : std_logic;
    signal lockedb1    : std_logic;
    signal lockedb2    : std_logic;

    signal ramWE       : std_logic := '0';
    signal ramAddrA    : std_logic_vector (15 downto 0) := (others => '0');
    signal ramAddrB    : std_logic_vector (15 downto 0) := (others => '0');
    signal ramDataIn   : std_logic_vector (3 downto 0) := (others => '0');
    signal ramDataOut  : std_logic_vector (3 downto 0) := (others => '0');

    signal border      : std_logic_vector (3 downto 0) := (others => '0');
    
    signal hCounter    : unsigned(10 downto 0):= (others => '0');
    signal vCounter    : unsigned(9 downto 0) := (others => '0');
    signal hCounter1   : unsigned(10 downto 0):= (others => '0');
    signal vCounter1   : unsigned(9 downto 0) := (others => '0');

    -- VGA Timing constants
    
    constant hMaxCount   : natural := 800;
    constant hStartData  : natural := 0;
    constant hEndData    : natural := 512;
    constant hStartBlank : natural := 576;
    constant hStartSync  : natural := 592;
    constant hEndSync    : natural := 688;
    constant hEndBlank   : natural := 736;

    constant vMaxCount   : natural := 524;
    constant vStartData  : natural := 0;
    constant vEndData    : natural := 384;
    constant vStartBlank : natural := 432;
    constant vStartSync  : natural := 444;
    constant vEndSync    : natural := 446;
    constant vEndBlank   : natural := 476;

begin

    led(1) <= NOT lockeda1;
    led(2) <= NOT lockeda2;
    led(3) <= NOT lockedb1;
    led(4) <= NOT lockedb2;

    test(1) <= atomClock;
    test(2) <= atomhSync;
    test(3) <= unused;
    test(4) <= rst;
    test(5) <= atomhSyncToggle;
    test(6) <= atomvSyncToggle;
    
    BUFG_1 : BUFG port map (
        O => clock32out,
        I => clock32
    );

    Inst_DCM_A: entity work.DCM_A port map (
      CLKIN_IN => clock32out,
      CLKFX_OUT => tmpVgaClock,
      LOCKED_OUT => lockeda1
    );

    Inst_DCM_A2: entity work.DCM_A2 port map (
        CLKIN_IN => tmpVgaClock,
        RST_IN => NOT lockeda1,
        CLKFX_OUT => pixelClock,
        LOCKED_OUT => lockeda2
    );
    
    Inst_DCM_B: entity work.DCM_B port map (
        CLKIN_IN => clock32out,
        CLKFX_OUT => tmpClock,
        LOCKED_OUT => lockedb1
    );

    Inst_DCM_C: entity work.DCM_C port map (
        CLKIN_IN => tmpClock,
        RST_IN => NOT lockedb1,
        CLKFX_OUT => atomClock,
        LOCKED_OUT => lockedb2
    );

    Inst_VideoRam: entity work.VideoRam port map (
        clka => atomClock,
        wea => ramWE,
        addra => ramAddrA,
        dina => ramDataIn,
        clkb => pixelClock,
        addrb => ramAddrB,
        doutb => ramDataOut
    );

    IBUFDS_1 : IBUFDS port map (
        O => AL0, -- Buffer output
        I => AL_P, -- Diff_p buffer input (connect directly to top-level port)
        IB => AL_N -- Diff_n buffer input (connect directly to top-level port)
    );
    
    IBUFDS_2 : IBUFDS port map (
        O => AH0, -- Buffer output
        I => AH_P, -- Diff_p buffer input (connect directly to top-level port)
        IB => AH_N -- Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS_3 : IBUFDS port map (
        O => BL0, -- Buffer output
        I => BL_P, -- Diff_p buffer input (connect directly to top-level port)
        IB => BL_N -- Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS_4 : IBUFDS port map (
        O => BH0, -- Buffer output
        I => BH_P, -- Diff_p buffer input (connect directly to top-level port)
        IB => BH_N -- Diff_n buffer input (connect directly to top-level port)
    );
    
    IBUFDS_5 : IBUFDS port map (
        O => L0, -- Buffer output
        I => LUM_P, -- Diff_p buffer input (connect directly to top-level port)
        IB => LUM_N -- Diff_n buffer input (connect directly to top-level port)
    );
            
    process(atomClock)
    begin
        if rising_edge(atomClock) then
          
            AL1 <= AL0;
            AH1 <= AH0;
            BL1 <= BL0;
            BH1 <= BH0;

            AL2 <= AL1;
            AH2 <= AH1;
            BL2 <= BL1;
            BH2 <= BH1;

            AL3 <= AL2;
            AH3 <= AH2;
            BL3 <= BL2;
            BH3 <= BH2;

            AL4 <= (AL1 AND AL2) OR (AL1 AND AL3) OR (AL2 AND AL3);
            AH4 <= (AH1 AND AH2) OR (AH1 AND AH3) OR (AH2 AND AH3);
            BL4 <= (BL1 AND BL2) OR (BL1 AND BL3) OR (BL2 AND BL3);
            BH4 <= (BH1 AND BH2) OR (BH1 AND BH3) OR (BH2 AND BH3);

            if (atomhcounter(2 downto 0) = unsigned(switch(7 downto 5))) then
                AL5 <= AL4;
                AH5 <= AH4;
                BL5 <= BL4;
                BH5 <= BH4;
            end if;

            L1 <= L0;
            L2 <= L1;
            L3 <= L2;
            L4 <= (L1 AND L2) OR (L1 AND L3) OR (L2 AND L3);
            
            if (atomhcounter(1 downto 0) = unsigned(switch(4 downto 3))) then
                L5 <= L4;
            end if;
            
            AL <= AL5;
            AH <= AH5;
            BL <= BL5;
            BH <= BH5;
            L  <= L5;

            --                 AL AH BL BH  L  R G1 G2  B
            --YELLOW   1.5 1.0  0  0  1  0  X  1  1  1  0
            --RED      2.0 1.5  0  1  0  0  X  1  0  1  0
            --MAGENTA  2.0 2.0  0  1  0  1  X  1  0  1  1
            --BUFF     1.5 1.5  0  0  0  0  1  1  1  1  1
            --ORANGE   2.0 1.0  0  1  1  0  1  1  1  0  0
             
            R <= (NOT AL AND NOT AH AND BL AND NOT BH) OR (NOT AL AND AH AND NOT BL AND NOT BH) OR (NOT AL AND AH AND NOT BL AND BH) OR (NOT AL AND NOT AH AND NOT BL AND NOT BH AND L) OR (NOT AL AND AH AND BL AND NOT BH AND L);

            --                 AL AH BL BH  L  R G1 G2  B
            --YELLOW   1.5 1.0  0  0  1  0  X  1  1  1  0
            --CYAN     1.0 1.5  1  0  0  0  X  0  1  1  1
            --GREEN    1.0 1.0  1  0  1  0  1  0  1  1  0
            --BUFF     1.5 1.5  0  0  0  0  1  1  1  1  1
            --ORANGE   2.0 1.0  0  1  1  0  1  1  1  0  0

            G1 <= (NOT AL AND NOT AH AND BL AND NOT BH) OR (AL AND NOT AH AND NOT BL AND NOT BH) OR (AL AND NOT AH AND BL AND NOT BH AND L) OR (NOT AL AND NOT AH AND NOT BL AND NOT BH AND L) OR (NOT AL AND AH AND BL AND NOT BH AND L);
            
            --                 AL AH BL BH  L  R G1 G2  B
            --ORANGE   2.0 1.0  0  1  1  0  1  1  1  0  0

            G2 <=  NOT (NOT AL AND AH AND BL AND NOT BH AND L);

            --                 AL AH BL BH  L  R G1 G2  B
            --BLUE     1.5 2.0  0  0  0  1  X  0  0  1  1
            --CYAN     1.0 1.5  1  0  0  0  X  0  1  1  1
            --MAGENTA  2.0 2.0  0  1  0  1  X  1  0  1  1
            --BUFF     1.5 1.5  0  0  0  0  1  1  1  1  1

            B <= (NOT AL AND NOT AH AND NOT BL AND BH) OR (AL AND NOT AH AND NOT BL AND NOT BH) OR (NOT AL AND AH AND NOT BL AND BH) OR (NOT AL AND NOT AH AND NOT BL AND NOT BH AND L);
    
            ramDataIn <= R & G1 & G2 & B;
                   
            -- generate a 1 clock hSync signal from the falling edge of sync
            atomhSync0 <= HS_N;
            atomhSync1 <= NOT atomhSync0;
            atomhSync2 <= atomhSync1;
            atomhSync3 <= atomhSync2;
            atomhSync4 <= atomhSync3;
            atomhSync5 <= atomhSync4;
            
            atomvSync0 <= FS_N;
            atomvSync1 <= NOT atomvSync0;
            atomvSync2 <= atomvSync1;
            atomvSync3 <= atomvSync2;
            atomvSync4 <= atomvSync3;
            atomvSync5 <= atomvSync4;

            if atomhSync5 = '1' AND atomhSync4 = '1' AND atomhSync3 = '0' AND atomhSync2 = '0'  then
                atomhSync <= '1';
            else
                atomhSync <= '0';
            end if;

            if atomvSync5 = '1' AND atomvSync4 = '1' AND atomvSync3 = '0' AND atomvSync2 = '0'  then
                atomvSync <= '1';
            else
                atomvSync <= '0';
            end if;
        
            -- generate 
            if (atomvSync = '1') then 
                atomvCounter <= atomvInit;
                atomvSyncToggle <= NOT atomvSyncToggle;
            elsif (atomhSync = '1') then
                atomvCounter <= atomvCounter+1;
            end if;
            
            if (atomhSync = '1') then
                 atomhCounter <= atomhInit;
                 atomhSyncToggle <= NOT atomhSyncToggle;
            else
                 atomhCounter <= atomhCounter+1;
            end if;

            ramAddrA <= std_logic_vector(atomvCounter(7 downto 0)) & std_logic_vector(atomhcounter(9 downto 2));            

            if (atomhcounter(1 downto 0) = unsigned(switch(2 downto 1)) AND atomhCounter < 1024 AND atomvCounter < 192) then
                ramWE <= '1';
            else
                ramWE <= '0';         
            end if;
            
            if (atomhcounter >= atomClampStart AND atomhCounter < atomClampEnd) then
                clamp <= '1';
            else
                clamp <= '0';         
            end if;
            
            if (atomhCounter = atomhBorder AND (switch(8) = '1' OR atomvCounter = atomvBorder)) then
                border <= ramDataIn;
            end if;

        end if;        
    end process;

    ramAddrB <= std_logic_vector(vCounter(8 downto 1)) & std_logic_vector(hcounter(8 downto 1));            

    process(pixelClock)
    begin
        if rising_edge(pixelClock) then
            hsync <= '0';      
            vsync <= '0';

            hCounter1 <= hCounter;
            vCounter1 <= vCounter;
            
            if (hCounter1 >= hStartData AND hCounter1 < hEndData AND vCounter1 >= vStartData AND vCounter1 < vEndData) then
                red   <= ramDataOut(3) & ramDataOut(3) & ramDataOut(3);
                green <= ramDataOut(2) & (ramDataOut(2) AND ramDataOut(1)) & (ramDataOut(2) AND ramDataOut(1));
                blue  <= ramDataOut(0) & ramDataOut(0);
            elsif (hCounter1 >= hStartBlank AND hCounter1 < hEndBlank) OR (vCounter1 >= vStartBlank AND vCounter1 < vEndBlank) then
                red   <= "000";
                green <= "000";
                blue  <= "00";            
            else
                red   <= border(3) & border(3) & border(3);
                green <= border(2) & (border(2) AND border(1)) & (border(2) AND border(1));
                blue  <= border(0) & border(0);
            end if;

            -- Count the lines and rows
            if hCounter = (hMaxCount - 1) then
                hCounter <= (others => '0');
                if (vCounter = vMaxCount - 1) then
                    vCounter <= (others => '0');
                else
                    vCounter <= vCounter+1;
                end if;
            else
                hCounter <= hCounter+1;
            end if;
            
            -- Are we in the hSync pulse?
            if hCounter >= hStartSync and hCounter < hEndSync then
                hSync <= '1';   -- Positive hSync pulse
            end if;

            -- Are we in the vSync pulse?
            if vCounter >= vStartSync and vCounter < vEndSync then
                vSync <= '1'; -- Positive vSync pulse
            end if;
        
        end if;
   end process;

end Behavioral;

