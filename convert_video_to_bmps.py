import cv2
import os
import sys
from PIL import Image

def extract_frames(video_path, output_folder, n_frames=20, prefix="frame", ext="bmp", width=576, height=136):
    # Create the output folder if it doesn't exist.
    os.makedirs(output_folder, exist_ok=True)
    
    # Open the video file.
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: Unable to open video file {video_path}")
        sys.exit(1)

    # Get total number of frames in the video.
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames == 0:
        print("Error: Unable to determine total frame count.")
        sys.exit(1)
    
    # Calculate indices for the frames you want to extract.
    # This creates a list of n_frames indices, evenly spaced throughout the video.
    frame_indices = [int(i * total_frames / n_frames) for i in range(n_frames)]
    print(f"Extracting {n_frames} frames at indices: {frame_indices}")

    current_index = 0
    extracted_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break  # End of video

        # If the current frame is one we want to extract...
        if current_index in frame_indices:
            # Resize the frame.
            frame = cv2.resize(frame, (width, height))
            
            # Convert the frame to grayscale.
            gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            
            # Convert grayscale frame to binary image.
            # Pixels above 127 become white (255) and the rest become black (0).
            _, bw_frame = cv2.threshold(gray_frame, 127, 255, cv2.THRESH_BINARY)
            
            # Convert the NumPy array to a PIL Image.
            pil_img = Image.fromarray(bw_frame)
            # Convert the image to 1-bit (mode "1") so that Pillow handles the BMP formatting.
            pil_img = pil_img.convert("1")
            
            # Build the filename.
            frame_filename = os.path.join(output_folder, f"{prefix}_{extracted_count:04d}.{ext}")
            
            # Save the image as a BMP.
            pil_img.save(frame_filename, format="BMP")
            print(f"Saved {frame_filename}")
            
            extracted_count += 1
            # If we've extracted enough frames, stop reading.
            if extracted_count >= n_frames:
                break
        current_index += 1

    cap.release()
    print(f"Done! Total frames extracted: {extracted_count}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python convert_video_to_bmps.py <video_file> <output_folder>")
        sys.exit(1)
    
    video_file = sys.argv[1]
    output_folder = sys.argv[2]
    extract_frames(video_file, output_folder)
