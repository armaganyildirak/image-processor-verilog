module gaussian_blur (
    input clk,
    input [7:0] pixel_in,
    output reg [7:0] pixel_out
);
    // Properly initialized Gaussian kernel
    reg [7:0] kernel [0:8];
    initial begin
        kernel[0] = 1; kernel[1] = 2; kernel[2] = 1;
        kernel[3] = 2; kernel[4] = 4; kernel[5] = 2;
        kernel[6] = 1; kernel[7] = 2; kernel[8] = 1;
    end
    
    // 3x3 pixel window buffer
    reg [7:0] window [0:8];
    reg [10:0] sum;
    integer i;
    
    // Track initialization state
    reg initialized = 0;
    integer init_counter = 0;
    
    always @(posedge clk) begin
        // Shift window
        for (i = 8; i > 0; i = i - 1)
            window[i] <= window[i-1];
        window[0] <= pixel_in;
        
        // Wait until window is filled with valid data
        if (init_counter < 9) begin
            init_counter <= init_counter + 1;
            pixel_out <= 0;
        end
        else begin
            // Compute convolution
            sum = 0;
            for (i = 0; i < 9; i = i + 1)
                sum = sum + (window[i] * kernel[i]);
            
            // Normalize and clamp output
            pixel_out <= (sum > 4080) ? 8'd255 : (sum >> 4);
        end
    end
endmodule