library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity fifo_testbench is
end fifo_testbench;
 
architecture rtl of fifo_testbench is
 
  constant DATA_WIDTH : integer := 8;
  constant FIFO_DEPTH : integer := 8;
 
  signal rst_n_s   : std_logic := '0';
  signal clk_s     : std_logic := '0';
  signal wr_en_s   : std_logic := '0';
  signal wr_data_s : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal full_s    : std_logic := '0';
  signal rd_en_s   : std_logic := '0';
  signal rd_data_s : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal empty_s   : std_logic := '0';
  signal fifo_data_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   
  component fifo is 
     port(
          data_out  : out std_logic_vector(7 downto 0);    
          fifo_full, fifo_empty, fifo_threshold, 
          fifo_overflow, fifo_underflow : out std_logic;
          clk   : in std_logic;  
          rst_n : in std_logic;  
          wr    : in  std_logic;
          rd    : in std_logic;
          data_in : in std_logic_vector(7 downto 0)
     );
  end component fifo;
 
   
begin
  
  fifo_inst : fifo
    --generic map(
      --DATA_WIDTH => DATA_WIDTH,
      --DEPTH      => FIFO_DEPTH
      --) 
    port map ( 
      clk   => clk_s,
      rst_n => rst_n_s,
      
      data_in        => wr_data_s,
      data_out       => rd_data_s,
      wr             => wr_en_s,
      rd             => rd_en_s,
      fifo_empty     => empty_s,
      fifo_full      => full_s,
      fifo_threshold => open,
      fifo_overflow  => open,
      fifo_underflow => open
    );
 
  clk_s <= not clk_s after 5 ns;

  -- Reset
  reset_process : process
  begin
    rst_n_s <= '0';
    wait for 20 ns;
    rst_n_s <= '1';
    wait;
  end process;
 
  -- Pisanie do FIFO
  p_wr_TEST : process is
    procedure push_fifo_data(data_in : std_logic_vector) is
    begin
      wait until full_s = '0' and rising_edge(clk_s);
      wr_en_s <= '1';
      wr_data_s <= data_in;
      wait until (rising_edge(clk_s));
      wr_en_s <= '0';
    end procedure;
  begin

    wait until rst_n_s = '1' and rising_edge(clk_s);

    -- Zapisz 32 dane do fifo, wartosci narastajco
    for i in 0 to 32 loop
      if i = 10 then
        push_fifo_data(std_logic_vector(to_unsigned(0, wr_data_s'length)));
      else
        push_fifo_data(std_logic_vector(to_unsigned(i, wr_data_s'length)));
      end if;
    end loop;

    wait;

  end process;

  -- Czytanie z FIFO
  p_rd_TEST : process is
    procedure read_fifo_data is
    begin
      wait until empty_s = '0' and rising_edge(clk_s);
      rd_en_s <= '1';
      wait until (rising_edge(clk_s));
      rd_en_s <= '0';
    end procedure;
  begin

    wait until rst_n_s = '1' and rising_edge(clk_s);

    -- Czytaj dane z fifo
    for i in 0 to 32 loop
      read_fifo_data;
      assert rd_data_s = std_logic_vector(to_unsigned(i, rd_data_s'length)) 
      report "Error, invalid data detected!" severity error;
      wait for 4*5 us;
    end loop;


    -- Syntentyczny blad który kończy symylację
    assert false severity failure;
 
  end process;
   
end rtl;