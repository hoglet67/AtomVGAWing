library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VideoRam is

    port (
        clka  : in  std_logic;
        wea   : in  std_logic;
        addra : in  std_logic_vector(15 downto 0);
        dina  : in  std_logic_vector(3 downto 0);
        clkb  : in  std_logic;
        addrb : in  std_logic_vector(15 downto 0);
        doutb : out std_logic_vector(3 downto 0)
        );
end VideoRam;

architecture BEHAVIORAL of VideoRam is

-- Shared memory
    type ram_type is array (48*1024-1 downto 0) of std_logic_vector (3 downto 0);
    shared variable RAM : ram_type;

--attribute RAM_STYLE : string;
--attribute RAM_STYLE of RAM: signal is "BLOCK";

begin

    process (clka)
    begin
        if rising_edge(clka) then
            if (wea = '1') then
                RAM(conv_integer(addra)) := dina;
            end if;
        end if;
    end process;

    process (clkb)
    begin
        if rising_edge(clkb) then
            doutb <= RAM(conv_integer(addrb));
        end if;
    end process;

end BEHAVIORAL;



