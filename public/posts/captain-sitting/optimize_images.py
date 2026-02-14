from PIL import Image
import os

def optimize_image(filepath, max_width=1200, quality=85):
    try:
        with Image.open(filepath) as img:
            # Convert RGBA to RGB if necessary
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            
            # Calculate new dimensions
            width, height = img.size
            if width > max_width:
                new_width = max_width
                new_height = int(height * (max_width / width))
                img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                print(f"Resized {filepath}: {width}x{height} -> {new_width}x{new_height}")
            
            # Save optimized image
            img.save(filepath, optimize=True, quality=quality)
            print(f"Optimized {filepath}")
            
    except Exception as e:
        print(f"Error optimizing {filepath}: {e}")

# Target directory
target_dir = r"c:\Users\capts\Desktop\myyacht\content\posts\captain-sitting"
files = ["captain-chair.png", "bearing-guide.png"]

for file in files:
    filepath = os.path.join(target_dir, file)
    if os.path.exists(filepath):
        optimize_image(filepath)
    else:
        print(f"File not found: {filepath}")
