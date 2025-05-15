`timescale 1ns/1ps
module tb_image_processor;
    parameter WIDTH = 128;
    parameter HEIGHT = 128;
    parameter TOTAL_PIXELS = WIDTH * HEIGHT;
    
    reg clk = 0;
    always #5 clk = ~clk;  // 100MHz clock
    
    reg [7:0] r, g, b;
    reg [7:0] threshold_val = 100;
    wire [7:0] gray, negative, blurred;
    wire binary;
    
    integer infile, outfile_gray, outfile_neg, outfile_bin, outfile_blur;
    integer i, r_val, g_val, b_val;
    reg file_end = 0;
    
    image_processor dut (
        .clk(clk),
        .r(r), .g(g), .b(b),
        .threshold_val(threshold_val),
        .gray(gray),
        .negative(negative),
        .binary(binary),
        .blurred(blurred)
    );
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_image_processor);
        
        infile = $fopen("input_image.txt", "r");
        if (infile == 0) begin
            $display("Error: Failed to open input file.");
            $finish;
        end
        
        outfile_gray = $fopen("output_gray.txt", "w");
        outfile_neg = $fopen("output_negative.txt", "w");
        outfile_bin = $fopen("output_binary.txt", "w");
        outfile_blur = $fopen("output_blurred.txt", "w");
        
        // Initialization period
        r = 0; g = 0; b = 0;
        #100;  // Wait for blur module to initialize
        
        // Process image
        i = 0;
        while (i < TOTAL_PIXELS) begin
            if ($fscanf(infile, "%d %d %d\n", r_val, g_val, b_val) != 3) begin
                $display("End of file at pixel %d", i);
                file_end = 1;
                i = TOTAL_PIXELS;  // Exit loop
            end
            else begin
                r = r_val;
                g = g_val;
                b = b_val;
                #20;  // Process for 2 clock cycles
                
                // Sanitize outputs before writing
                $fwrite(outfile_gray, "%d\n", gray);
                $fwrite(outfile_neg, "%d\n", negative);
                $fwrite(outfile_bin, "%d\n", binary ? 1 : 0);
                $fwrite(outfile_blur, "%d\n", blurred);
                
                i = i + 1;
            end
        end
        
        $fclose(infile);
        $fclose(outfile_gray);
        $fclose(outfile_neg);
        $fclose(outfile_bin);
        $fclose(outfile_blur);
        
        if (!file_end) begin
            $display("Processing complete. All %0d pixels processed.", TOTAL_PIXELS);
        end else begin
            $display("Processing stopped. %0d pixels processed.", i);
        end
        $finish;
    end
endmodule