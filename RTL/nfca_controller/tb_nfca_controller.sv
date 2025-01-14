`timescale 1ns/1ns

module tb_nfca_controller ();

reg clk = 1'b0;
always #6 clk = ~clk;   // 81.36MHz approx.


reg        tx_tvalid = 1'b0;
wire       tx_tready;
reg  [7:0] tx_tdata  = '0;
reg        tx_tlast  = '0;
reg  [2:0] tx_tlastb = '0;

wire       carrier_out;


nfca_controller nfca_controller_i (
    .rstn          ( 1'b1              ),
    .clk           ( clk               ),
    .tx_tvalid     ( tx_tvalid         ),
    .tx_tready     ( tx_tready         ),
    .tx_tdata      ( tx_tdata          ),
    .tx_tlast      ( tx_tlast          ),
    .tx_tlastb     ( tx_tlastb         ),
    .adc_data_en   ( '0                ),
    .adc_data      ( '0                ),
    .carrier_out   ( carrier_out       )
);


task automatic tx_frame(input logic [7:0] data_array [], input logic [2:0] lastb = 3'd7);
    {tx_tvalid, tx_tdata, tx_tlast, tx_tlastb} <= 1'b0;
    @ (posedge clk);
    foreach(data_array[ii]) begin
        tx_tvalid <= 1'b1;
        tx_tdata  <= data_array[ii];
        tx_tlast  <= ii+1 == $size(data_array);
        tx_tlastb <= ii+1 == $size(data_array) ? lastb : 3'd7;
        @ (posedge clk);
        while(~tx_tready) @ (posedge clk);
    end
    {tx_tvalid, tx_tdata, tx_tlast, tx_tlastb} <= 1'b0;
endtask


initial begin
    tx_frame('{8'h26});
    tx_frame('{8'h12, 8'h34});
    tx_frame('{8'h12, 8'h34, 8'h12}, 3'd5);
    tx_frame('{8'h93, 8'h56, 8'h12}, 3'd6);
    tx_frame('{8'h93, 8'h56, 8'h12, 8'h34}, 3'd0);
    tx_frame('{8'h95, 8'h70, 8'h12, 8'h34});
    tx_frame('{8'h95, 8'h6f, 8'h12, 8'h34});
    @ (posedge clk);
    while(~tx_tready) @ (posedge clk);
    repeat(10000) @ (posedge clk);
    $stop;
end


endmodule

