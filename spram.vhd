----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Jacek Mamrot
-- 
-- Create Date:    20:54:22 12/09/2016 
-- Design Name:    Sinmgle Port RAM
-- Module Name:    spram
-- Project Name:   SPRAM
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

entity dpram is
  generic (
    DATA_WIDTH : integer := 8;
    DEPTH      : integer := 8
    );
  port ( 
    clk_a     : in  std_logic;
    reset_a_n : in  std_logic;

    port_a_address   : in std_logic_vector(DEPTH-1 downto 0);
    port_a_readdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    port_a_writedata : in std_logic_vector(DATA_WIDTH-1 downto 0);
    port_a_write     : in std_logic
  );
end dpram;

architecture rtl of dpram is

  type ram_t is array (0 to 2**DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable mem : ram_t;

begin

  port_a_proc : process(clk_a)
  begin
    if rising_edge(clk_a) then
      if port_a_write = '1' then
        mem(to_integer(unsigned(port_a_address))) := port_a_writedata;
      end if;
      port_a_readdata <= mem(to_integer(unsigned(port_a_address)));
    end if;
  end process;

end rtl;