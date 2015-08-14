--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.4
--  \   \         Application : xaw2vhdl
--  /   /         Filename : DCM_B.vhd
-- /___/   /\     Timestamp : 03/01/2013 20:52:36
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-intstyle /home/dmb/papilio/projects/VGATest/ipcore_dir/DCM_B.xaw -st DCM_B.vhd
--Design Name: DCM_B
--Device: xc3s500e-5vq100
--
-- Module DCM_B
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST
-- Period Jitter (unit interval) for block DCM_SP_INST = 0.05 UI
-- Period Jitter (Peak-to-Peak) for block DCM_SP_INST = 3.61 ns

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity DCM_B is
   port ( CLKIN_IN   : in    std_logic; 
          CLKFX_OUT  : out   std_logic; 
          LOCKED_OUT : out   std_logic);
end DCM_B;

architecture BEHAVIORAL of DCM_B is
   signal CLKFX_BUF  : std_logic;
   signal GND_BIT    : std_logic;
begin
   GND_BIT <= '0';
   CLKFX_BUFG_INST : BUFG
      port map (I=>CLKFX_BUF,
                O=>CLKFX_OUT);
   
   DCM_SP_INST : DCM_SP
   generic map( CLK_FEEDBACK => "NONE",
            CLKDV_DIVIDE => 2.0,
            CLKFX_DIVIDE => 32,
            CLKFX_MULTIPLY => 15,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 31.250,
            CLKOUT_PHASE_SHIFT => "NONE",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"C080",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE)
      port map (CLKFB=>GND_BIT,
                CLKIN=>CLKIN_IN,
                DSSEN=>GND_BIT,
                PSCLK=>GND_BIT,
                PSEN=>GND_BIT,
                PSINCDEC=>GND_BIT,
                RST=>GND_BIT,
                CLKDV=>open,
                CLKFX=>CLKFX_BUF,
                CLKFX180=>open,
                CLK0=>open,
                CLK2X=>open,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open,
                STATUS=>open);
   
end BEHAVIORAL;

