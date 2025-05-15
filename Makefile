# Configurations
IMAGE_WIDTH  := 128
IMAGE_HEIGHT := 128
INPUT_IMAGE  := input.png
THRESHOLD    := 100

# Verilog source files
VERILOG_SRC := grayscale.v inverter.v threshold.v gaussian_blur.v image_processor.v
TB_TOP      := tb_image_processor.v

# Python script
PY_SCRIPT   := process_image.py

# Output files
SIM_BINARY  := sim
VCD_OUT     := waveform.vcd
TXT_INPUT   := input_image.txt
TXT_OUTPUTS := output_gray.txt output_negative.txt output_binary.txt output_blurred.txt
PNG_OUTPUTS := gray_output.png negative_output.png binary_output.png blurred_output.png

.PHONY: all clean simulate convert

all: simulate convert

# Generate input text file from PNG
$(TXT_INPUT):
	@echo "[PYTHON] Converting $(INPUT_IMAGE) to $(TXT_INPUT)"
	@python $(PY_SCRIPT)

# Run Verilog simulation
simulate: $(TXT_INPUT)
	@echo "[VERILOG] Compiling & simulating..."
	@if ! iverilog -o $(SIM_BINARY) $(TB_TOP) $(VERILOG_SRC); then \
		echo "[ERROR] Verilog compilation failed."; \
		exit 1; \
	fi
	@vvp $(SIM_BINARY)
	@echo "[VERILOG] Simulation complete. Outputs: $(TXT_OUTPUTS)"

# Convert output .txt files to .png
convert:
	@echo "[PYTHON] Generating output images..."
	@python $(PY_SCRIPT)
	@echo "[PYTHON] Output images: $(PNG_OUTPUTS)"

view:
	@gtkwave $(VCD_OUT)

# Clean generated files
clean:
	@echo "[CLEAN] Removing generated files..."
	@rm -f $(SIM_BINARY) $(VCD_OUT) $(TXT_INPUT) $(TXT_OUTPUTS) $(PNG_OUTPUTS)

run: all