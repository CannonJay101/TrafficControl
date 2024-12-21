// Code your design here
module traffic_control (
    input clk, //* Clock signal
    input rst_n, //* Reset signal (reset=0)
    input sensor, //* Sensor signal

    output reg [2:0] Highway_Light, Farm_Light //* Highway traffic light
);
    



    //* Defining parameters for the state machine
    parameter
    HighwayGreen_FarmRed = 2'b00,   //* highway green light and farm red light
    HighwayYellow_FarmRed = 2'b01,  //* highway yellow light and farm red light
    HighwayRed_FarmGreen = 2'b10,   //* highway red light and farm green light
    HighwayRed_FarmYellow = 2'b11;  //* highway red light and farm yellow light


    reg[27:0] count=0,count_delay=0; //* Clock that can store numbers from 0 to 2^28-1, count_delay is used to store the count value for 10s delay for yellow lights
    reg delay10s=0, delay3s1=0,delay3s2=0,RED_count_en=0,YELLOW_count_en1=0,YELLOW_count_en2=0;//* 1 bit registers, including the delays for red and yellow lights
    wire clk_enable; //* clock enable signal for 1s
    reg[1:0] state, next_state;
    
    always @(posedge clk or negedge rst_n) //* Positive edge of clock or negative edge of reset
    begin
        if(~rst_n) //* If reset is active
        state <= HighwayGreen_FarmRed; //* Reset state to highway green and farm red;
        else
        state <= next_state;
    end

//* Start of FSM for traffic control
    always @(*)
    begin
        case(state)

            HighwayGreen_FarmRed: //* Condition for green light on highway and red light on farm
            begin
                RED_count_en=0;     //* Resetting the count for red light
                YELLOW_count_en1=0; //* Resetting the count for yellow light
                YELLOW_count_en2=0; //* Resetting the count for yellow light
                Highway_Light = 3'b001; //* Green light on highway
                Farm_Light = 3'b100;    //* Red light on farm
                if(sensor) //* If sensor is detects vehicle on farm, change the state to HighwayYellow
                next_state = HighwayYellow_FarmRed;
                else
                next_state = HighwayGreen_FarmRed; //* If no vehicle is detected, stay in the same state
            end

            HighwayYellow_FarmRed: //! Condition for yellow light on highway and red light on farm
            begin
                RED_count_en=0;     //* Resetting the count for red light
                YELLOW_count_en1=1; //* Enabling the count for yellow light for highway light
                YELLOW_count_en2=0; //* Resetting the count for yellow light
                Highway_Light = 3'b010; //* Yellow light on highway
                Farm_Light = 3'b100;    //* Red light on farm
                if(sensor) //* If sensor is detects vehicle on farm, change the state to HighwayRed
                next_state = HighwayRed_FarmGreen;
                else
                next_state = HighwayYellow_FarmRed;
            end

            HighwayRed_FarmGreen: //! Condition for red light on highway and green light on farm
            begin
                RED_count_en=1;     //* Enabling the count for red light
                YELLOW_count_en1=0; //* Resetting the count for yellow light for highway light
                YELLOW_count_en2=0; //* Resetting the count for yellow light for farm light
                Highway_Light = 3'b100;
                Farm_Light = 3'b001;
                if(sensor) //* If sensor is detects vehicle on highway, change the state to HighwayYellow
                next_state = HighwayRed_FarmYellow;
                else
                next_state = HighwayRed_FarmGreen;
            end

            HighwayRed_FarmYellow: //! Condition for red light on highway and yellow light on farm
            begin
                RED_count_en=0;     //* Resetting the count for red light
                YELLOW_count_en1=0; //* Resetting the count for yellow light for highway light  
                YELLOW_count_en2=1; //* Enabling the count for yellow light for farm light
                Highway_Light = 3'b100;
                Farm_Light = 3'b010;
                if(sensor) //* If sensor is detects vehicle on highway, change the state to HighwayGreen
                next_state = HighwayGreen_FarmRed;
                else
                next_state = HighwayRed_FarmYellow;
            end

            default: next_state = HighwayGreen_FarmRed; //! Default state is highway green and farm red
            
        endcase
    end

    //*creating delay for Red light and Yellow light
    always @(posedge clk)
    begin
        if(clk_enable == 1) begin
            if(RED_count_en || YELLOW_count_en1 || YELLOW_count_en2) begin //* returns true if any of the operands are 1, returns 0 if all are 0
                count <= count + 1; //* Incrementing the count
            end
            if((count_delay == 9) && RED_count_en) begin //* Logical AND operation for count delay = 9 and REDCOUNT = 1
                delay10s = 1; //* Enabling the 10s delay
                delay3s1 = 0; //* Disabling the 3s delay
                delay3s2 = 0; //* Disabling the 3s delay
                count_delay = 0; //* Resetting the count delay
            end
            else if((count_delay == 2) && YELLOW_count_en1) begin  //* count delay = 2 and YELLOWCOUNT = 1
                delay10s = 0; //* Disabling the 10s delay
                delay3s1 = 1; //* Enabling the 3s delay
                delay3s2 = 0; //* Disabling the 3s delay
                count_delay = 0; //* Resetting the count delay
            end
            else if((count_delay == 2) && YELLOW_count_en2) begin //* count delay = 2 and YELLOWCOUNT = 1
                delay10s = 0; //* Disabling the 10s delay
                delay3s1 = 0; //* Disabling the 3s delay
                delay3s2 = 1; //* Enabling the 3s delay
                count_delay = 0; //* Resetting the count delay
            end
            else begin
                delay10s = 0; //* Disabling the 10s delay
                delay3s1 = 0; //* Disabling the 3s delay
                delay3s2 = 0; //* Disabling the 3s delay
            end
        end;
    
        count <= count + 1; //* Incrementing the count
        if(count == 3) begin 
            count <= 0; //* Reset the count
        end;
    end;
    
    assign clk_enable = (count == 3) ? 1 : 0; //* If count is 3, enable the clock, else disable the clock


endmodule