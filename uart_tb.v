`timescale 1 ns / 1 ps
module uart_tb;
	// Inputs
	reg reset;
	reg txclk;
	reg ld_tx_data;
	reg [7:0] tx_data;
	reg tx_enable;
	reg rxclk;
	reg uld_rx_data;
	reg rx_enable;
	reg rx_in;

	// Outputs
	wire tx_out;
	wire tx_empty;
	wire [7:0] rx_data;
	wire rx_empty;

  // uncomment lines for convenient access to internal var
  //wire [7:0] rx_reg = uut.rx_reg;
  //wire [3:0] rx_cnt = uut.rx_cnt;
  //wire [3:0] rx_sample_cnt = uut.rx_sample_cnt;
  //wire rx_d2 = uut.rx_d2;
  //wire rx_busy = uut.rx_busy;
  
	// Instantiate the Unit Under Test (UUT)
	uart uut (
		.reset(reset), 
		.txclk(txclk), 
		.ld_tx_data(ld_tx_data), 
		.tx_data(tx_data), 
		.tx_enable(tx_enable), 
		.tx_out(tx_out), 
		.tx_empty(tx_empty), 
		.rxclk(rxclk), 
		.uld_rx_data(uld_rx_data), 
		.rx_data(rx_data), 
		.rx_enable(rx_enable), 
		.rx_in(rx_in), 
		.rx_empty(rx_empty)
	);

  //generate a master clk
  reg clk;
  //setup clocks
  initial clk=0;
  always #10 clk = ~clk;  //this speed is somewhat arbitrary for the purposes of this sim...clk should be 16X faster than desired baud rate.  I like my simulation time to match the physical system.

  //generate rxclk and txclk so that txclk is 16 times slower than rxclk
  reg [3:0] counter;
  initial begin
    rxclk=0;
    txclk=0;
    counter=0;
  end
  always @(posedge clk) begin
    counter<=counter+1;
    if (counter == 15) txclk <= ~txclk;
    rxclk<= ~rxclk;
  end

  //setup loopback
  always @ (tx_out) rx_in=tx_out;

	initial begin
		// Initialize Inputs
		reset = 1;
		ld_tx_data = 0;
		tx_data = 0;
		tx_enable = 1;
		uld_rx_data = 0;
		rx_enable = 1;
//		rx_in = 1;

		// Wait 100 ns for global reset to finish
		#500;
		reset = 0;


		// Add stimulus here 
    // Send data using tx portion of UART and wait until data is recieved
		tx_data=8'b0111_1111;
		#500;
    wait (tx_empty==1);  //make sure data can be sent
    ld_tx_data = 1;      //load data to send
    wait (tx_empty==0);  //wait until data loaded for send
    $display("Data loaded for send");
    ld_tx_data = 0;
    wait (tx_empty==1);  //wait for flag of data to finish sending
    $display("Data sent");
    wait (rx_empty==0);  //wait for 
    $display("RX Byte Ready");
		uld_rx_data = 1;
    wait (rx_empty==1);
    $display("RX Byte Unloaded: %b",rx_data);
    #100;
	   
    $finish;
end    
endmodule
