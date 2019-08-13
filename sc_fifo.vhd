----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Jacek Mamrot
-- 
-- Create Date:    20:54:22 12/09/2016 
-- Design Name:    Single Clock FIFO
-- Module Name:    SC FIFO
-- Project Name:   SC FIFO
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

entity sc_fifo is
  generic (
    DATA_WIDTH : integer := 8;
    DEPTH      : integer := 8
    );
  port ( 
    clk   : in  std_logic;
    rst_n : in  std_logic;

    data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wrreq    : in  std_logic;
    rdreq    : in  std_logic;
    empty    : out std_logic;
    full     : out std_logic;
    wrusedw  : out std_logic_vector(DEPTH-1 downto 0)
  );
end sc_fifo;

architecture rtl of sc_fifo is

  component dpram is
    generic (
      DATA_WIDTH : integer := 8;
      DEPTH      : integer := 8
      );
    port ( 
      clk_a     : in  std_logic;
      reset_a_n : in  std_logic;
      clk_b     : in  std_logic;
      reset_b_n : in  std_logic;

      port_a_address   : in std_logic_vector(DEPTH-1 downto 0);
      port_a_readdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
      port_a_writedata : in std_logic_vector(DATA_WIDTH-1 downto 0);
      port_a_write     : in std_logic;
      
      port_b_address   : in std_logic_vector(DEPTH-1 downto 0);
      port_b_readdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
      port_b_writedata : in std_logic_vector(DATA_WIDTH-1 downto 0);
      port_b_write     : in std_logic
    );
  end component;

  signal wr_addr_r : std_logic_vector(DEPTH-1 downto 0);
  signal rd_addr_r : std_logic_vector(DEPTH-1 downto 0);

  signal full_r : std_logic;
  signal empty_r : std_logic;
  
begin
  
  dpram_inst : dpram
    generic map(
      DATA_WIDTH => DATA_WIDTH,
      DEPTH      => DEPTH
    ) port map (
      clk_a     => clk,
      reset_a_n => rst_n,
      clk_b     => clk,
      reset_b_n => rst_n,

      port_a_address   => wr_addr_r,
      port_a_readdata  => open,
      port_a_writedata => data_in,
      port_a_write     => wrreq,
      
      port_b_address   => rd_addr_r,
      port_b_readdata  => data_out,
      port_b_writedata => (others => '0'),
      port_b_write     => '0'
    );

  arrd_gen_proc : process(clk, rst_n)
  begin
    if rst_n = '0' then
      wr_addr_r <= (others => '0');
      rd_addr_r <= (others => '0');
      full_r <= '0';
      empty_r <= '1';
    elsif rising_edge(clk) then
      if wrreq = '1' then
        wr_addr_r <= wr_addr_r + 1;
      end if;
      if rdreq = '1' then
        rd_addr_r <= rd_addr_r + 1;
      end if;

      if wr_addr_r = rd_addr_r - 1 and wrreq = '1' then
        full_r <= '1';
      elsif rdreq = '1' then
        full_r <= '0';
      end if;

      if rd_addr_r = wr_addr_r - 1 and rdreq = '1' then
        empty_r <= '1';
      elsif wrreq = '1' then
        empty_r <= '0';
      end if;      
    end if;
  end process;

  empty <= empty_r;
  full <= full_r;

  --wrusedw <= rd_addr_r - wr_addr_r when rd_addr_r > wr_addr_r else
  --           wr_addr_r - rd_addr_r when wr_addr_r > rd_addr_r else
  --           (others => '0');
	 
end rtl;