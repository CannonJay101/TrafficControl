`timescale 10ns/1ps

module traffic_controlTB;

parameter ENDTIME = 2000; //* Simulation end time

//* Inputs
reg clk, rst_n, sensor;

//* Outputs
wire [2:0] Highway_Light, Farm_Light;

//* Instantiate the DUT
traffic_control DUT (
    .clk(clk),
    .rst_n(rst_n),
    .sensor(sensor),
    .Highway_Light(Highway_Light),
    .Farm_Light(Farm_Light)
);

//* Clock Generation
initial begin
    clk = 0;
end
always #5 clk = ~clk; //* Generate a clock with a period of 10ns

//* Reset Generation
initial begin
    rst_n = 0; //* Apply reset
    #20 rst_n = 1; //* Release reset after 20ns
end

//* Stimulus Generation
initial begin
    sensor = 0; //* Initially no vehicle detected on farm road
    #100;       //* Wait 100ns
    sensor = 1; //* Vehicle detected on farm road
    #300;       //* Wait 300ns
    sensor = 0; //* Vehicle cleared
    #200;       //* Wait 200ns
    sensor = 1; //* Another vehicle detected on farm road
    #400;       //* Wait 400ns
    sensor = 0; //* No vehicle detected
    #300;       //* Wait 300ns
end

//* Monitor Outputs
initial begin
    $display("--------------------------------------------------");
    $display("---------------- SIMULATION START ----------------");
    $display("--------------------------------------------------");
    $monitor("TIME = %t | reset = %b | sensor = %b | Highway Light = %h | Farm Light = %h",
             $time, rst_n, sensor, Highway_Light, Farm_Light);
end

//* End Simulation
initial begin
    #ENDTIME;
    $display("--------------------------------------------------");
    $display("---------------- SIMULATION END ------------------");
    $display("--------------------------------------------------");
    $finish;
end

endmodule
