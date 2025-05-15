from PIL import Image
import numpy as np
import os

def image_to_txt(image_path, out_path, width=128, height=128):
    try:
        img = Image.open(image_path).convert("RGB")
        if img.size != (width, height):
            print(f"Resizing image from {img.size} to ({width}, {height})")
            img = img.resize((width, height))
        
        pixels = np.array(img).reshape(-1, 3)
        with open(out_path, "w") as f:
            for r, g, b in pixels:
                f.write(f"{r} {g} {b}\n")
        print(f"Successfully converted {image_path} to {out_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {str(e)}")
        raise

def txt_to_image(txt_path, out_path, width=128, height=128, mode="L", threshold=False):
    if not os.path.exists(txt_path):
        return
    
    try:
        with open(txt_path, "r") as f:
            lines = f.readlines()
            data = []
            invalid_count = 0
            
            for line in lines:
                val = line.strip()
                try:
                    num = int(val)
                    if threshold:
                        num = 255 if num == 1 else 0
                    data.append(num)
                except ValueError:
                    invalid_count += 1
                    data.append(0)  # Default fallback
            
            if invalid_count > 0:
                print(f"Warning: {invalid_count} invalid values in {txt_path}, replaced with 0")
            
            if len(data) != width * height:
                print(f"Warning: Expected {width * height} pixels, got {len(data)}")
            
            img = Image.new(mode, (width, height))
            img.putdata(data)
            img.save(out_path)
            print(f"Successfully saved {out_path}")
    except Exception as e:
        print(f"Error processing {txt_path}: {str(e)}")
        raise

if __name__ == "__main__":
    WIDTH, HEIGHT = 128, 128
    
    input_img = "input.png"
    input_txt = "input_image.txt"
    
    if not os.path.exists(input_txt):
        if not os.path.exists(input_img):
            raise FileNotFoundError(f"Neither {input_img} nor {input_txt} found")
        image_to_txt(input_img, input_txt, WIDTH, HEIGHT)
    
    txt_to_image("output_gray.txt", "gray_output.png", WIDTH, HEIGHT)
    txt_to_image("output_negative.txt", "negative_output.png", WIDTH, HEIGHT)
    txt_to_image("output_binary.txt", "binary_output.png", WIDTH, HEIGHT, threshold=True)
    txt_to_image("output_blurred.txt", "blurred_output.png", WIDTH, HEIGHT)