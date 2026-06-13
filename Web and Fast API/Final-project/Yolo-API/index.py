import os
import logging
import asyncio
import numpy as np
import cv2
import requests
from datetime import datetime
from collections import Counter
from typing import List
from fastapi import FastAPI, HTTPException, Body
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from ultralytics import YOLO
from PIL import Image, ImageDraw, ImageFont
from io import BytesIO
from scipy.ndimage import gaussian_filter
from pydantic import BaseModel
from PIL import ImageFont


# Configure Logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Load YOLO Model Globally (Avoid Reloading on Each Request)
try:
    MODEL_PATH = "best.pt"
    model = YOLO(MODEL_PATH)
    logger.info("YOLO model loaded successfully.")
except Exception as e:
    logger.error(f"Failed to load YOLO model: {e}")
    raise

# Define PCB Defect Class Names
CLASS_NAMES = {
    0: "Missing Holes",
    1: "Mouse Bites",
    2: "Open Circuit",
    3: "Short Circuit",
    4: "Spurious Copper",
    5: "Spurs"
}

CLASS_COLORS = {
    "Missing Holes": "yellow",
    "Mouse Bites": "blue",
    "Open Circuit": "green",
    "Short Circuit": "red",
    "Spurious Copper": "orange",
    "Spurs": "purple"
}

# Setup FastAPI App
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create Static Directory for Storing Images
STATIC_DIR = "./static"
os.makedirs(STATIC_DIR, exist_ok=True)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# Define Pydantic Model for Image URLs
class ImageUrls(BaseModel):
    images: List[str]

# Async Function to Generate Heatmap
async def generate_heatmap(orig_img: np.ndarray, predictions: List[dict], img_shape: tuple) -> Image:
    try:
        # Create an empty heatmap (same size as the image)
        heatmap = np.zeros(img_shape, dtype=np.float32)

        # Loop through all predicted boxes
        for pred in predictions:
            x_min, y_min, x_max, y_max = pred['x_min'], pred['y_min'], pred['x_max'], pred['y_max']
            confidence = pred['confidence']

            # Create a mask for the bounding box
            bbox_mask = np.zeros(img_shape, dtype=np.float32)
            bbox_mask[y_min:y_max, x_min:x_max] = confidence

            # Apply Gaussian smoothing to the bounding box region
            bbox_mask = gaussian_filter(bbox_mask, sigma=10)  # Adjust sigma for smoothness

            # Add the smoothed mask to the heatmap
            heatmap += bbox_mask

        # Normalize the heatmap to range [0, 1] for visualization
        if heatmap.max() > 0:
            heatmap = heatmap / heatmap.max()

        # Apply the 'jet' colormap to the heatmap
        heatmap_color = cv2.applyColorMap((heatmap * 255).astype(np.uint8), cv2.COLORMAP_JET)

        # Blend the heatmap with the original image
        overlay_img = cv2.addWeighted(orig_img, 0.6, heatmap_color, 0.4, 0)

        # Convert the overlay image to PIL format
        overlay_img_rgb = cv2.cvtColor(overlay_img, cv2.COLOR_BGR2RGB)
        heatmap_pil = Image.fromarray(overlay_img_rgb)

        return heatmap_pil
    except Exception as e:
        logger.error(f"Error generating heatmap: {e}")
        return None

# Function to Generate Annotated Image
async def generate_annotated_image(orig_img: np.ndarray, predictions: List[dict]) -> Image:
    try:
        # Convert the original image to RGB for PIL processing
        annotated_img = cv2.cvtColor(orig_img, cv2.COLOR_BGR2RGB)
        annotated_pil = Image.fromarray(annotated_img)
        draw = ImageDraw.Draw(annotated_pil)

        # Try loading custom font, fallback if not available
        try:
            font_path = "/usr/share/fonts/truetype/msttcorefonts/arialbd.ttf"  # Bold Arial
            font = ImageFont.truetype(font_path, size=13)
        except IOError:
            font = ImageFont.load_default()

        # Draw bounding boxes and labels
        for pred in predictions:
            x_min, y_min, x_max, y_max = pred['x_min'], pred['y_min'], pred['x_max'], pred['y_max']
            confidence = pred['confidence']
            class_name = pred['class_name']
            color = CLASS_COLORS.get(class_name, "white")  # Fallback color

            # Draw bounding box
            draw.rectangle([x_min, y_min, x_max, y_max], outline=color, width=3)

            # Draw label background for readability
            label = f"{class_name} ({confidence:.2f})"
            bbox = draw.textbbox((0, 0), label, font=font)
            text_size = (bbox[2] - bbox[0], bbox[3] - bbox[1])  # width, height
            label_bg = [x_min, y_min - text_size[1], x_min + text_size[0], y_min]
            draw.rectangle(label_bg, fill=color)

            # Draw label text
            draw.text((x_min, y_min - text_size[1]), label, fill="black", font=font)

        return annotated_pil

    except Exception as e:
        logger.error(f"Error generating annotated image: {e}")
        return None

# Function to Predict Defects in a Single Image
async def predict(image: Image) -> dict:
    try:
        img_np = np.array(image)
        img_np = cv2.cvtColor(img_np, cv2.COLOR_RGB2BGR)
        logger.info(f"[PREDICT] Image shape: {img_np.shape}, dtype: {img_np.dtype}")

        # Predict with YOLO and capture speed info
        results = model.predict(source=img_np, save=False, conf=0.25, verbose=False)
        result = results[0]  # Single image
        boxes = result.boxes
        speed = result.speed  # Dict with 'preprocess', 'inference', 'postprocess'

        # Create detection summary (e.g., 3 Spurs, 2 Short Circuit)
        class_counts = Counter()
        predictions = []

        for box in boxes:
            x_min, y_min, x_max, y_max = map(int, box.xyxy[0])
            confidence = float(box.conf[0])
            class_id = int(box.cls[0])
            class_name = CLASS_NAMES.get(class_id, "Unknown")
            class_counts[class_name] += 1

            predictions.append({
                "class_id": class_id,
                "class_name": class_name,
                "confidence": confidence,
                "x_min": x_min,
                "y_min": y_min,
                "x_max": x_max,
                "y_max": y_max
            })

        logger.info(f"[PREDICT] Parsed {len(predictions)} predictions.")

        # Construct detection summary string
        if predictions:
            summary_parts = [f"{count} {cls}" for cls, count in class_counts.items()]
            detection_summary = f"{len(predictions)} detections: " + ", ".join(summary_parts)
        else:
            detection_summary = "No defects detected."

        # Get image dimensions and speed info
        img_shape = img_np.shape[:2]
        heatmap_img = await generate_heatmap(img_np, predictions, img_shape)
        annotated_img = await generate_annotated_image(img_np, predictions)

        return {
            "predictions": predictions,
            "annotated_img": annotated_img,
            "heatmap_img": heatmap_img,
            "detection_summary": detection_summary,
            "speed_info": {
                "preprocess_ms": round(speed["preprocess"], 2),
                "inference_ms": round(speed["inference"], 2),
                "postprocess_ms": round(speed["postprocess"], 2)
            }
        }

    except Exception as e:
        logger.error(f"[PREDICT ERROR] {e}")
        return {
            "predictions": [],
            "annotated_img": None,
            "heatmap_img": None,
            "detection_summary": "Error during prediction.",
            "speed_info": {}
        }

# Async Function to Process Each Image from URL
async def process_image(image_url: str) -> dict:
    try:
        # Download image from URL with proper headers
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        response = requests.get(image_url, headers=headers, stream=True)
        response.raise_for_status()

        # Read the image content into memory
        image_content = response.raw.read()
        img = Image.open(BytesIO(image_content)).convert("RGB")

        # Get the result from predict as a dictionary
        result = await predict(img)
        predictions = result["predictions"]
        annotated_img = result["annotated_img"]
        heatmap_img = result["heatmap_img"]
        speed_info = result["speed_info"]

        if annotated_img is None or heatmap_img is None:
            raise Exception("Prediction or heatmap generation failed.")

        # Save annotated and heatmap images
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        annotated_path = os.path.join(STATIC_DIR, f"annotated_{timestamp}.jpg")
        heatmap_path = os.path.join(STATIC_DIR, f"heatmap_{timestamp}.jpg")
        annotated_img.save(annotated_path, quality=95)  # Higher quality JPEG
        heatmap_img.save(heatmap_path, quality=95)      # Higher quality JPEG

        return {
            "image_url": image_url,
            "predictions": predictions,
            "annotated_image_url": f"/static/{os.path.basename(annotated_path)}",
            "heatmap_url": f"/static/{os.path.basename(heatmap_path)}",
            "speed_info": speed_info  # Include speed_info for each image
        }
    except Exception as e:
        logger.error(f"Error processing image {image_url}: {e}")
        return {"image_url": image_url, "error": str(e)}
    finally:
        response.close()  # Ensure the response stream is closed

# FastAPI Endpoint for Batch Prediction
@app.post("/batch-predict")
async def batch_predict(image_data: ImageUrls = Body(...)):
    if not image_data.images:
        raise HTTPException(status_code=400, detail="No image URLs provided.")

    # Process images concurrently
    results = await asyncio.gather(*[process_image(url) for url in image_data.images])

    # Compute defect statistics
    total_defect_counts = Counter()
    pcb_defect_counts = Counter()
    total_images = len(image_data.images)

    # Initialize variables for aggregating speed info
    total_preprocess = 0
    total_inference = 0
    total_postprocess = 0
    successful_images = 0

    for result in results:
        if "predictions" in result and result["predictions"]:
            defect_classes = set()
            for pred in result["predictions"]:
                total_defect_counts.update([pred["class_id"]])
                defect_classes.add(pred["class_id"])
            for class_id in defect_classes:
                pcb_defect_counts[class_id] += 1

        # Aggregate speed information
        if "speed_info" in result and result["speed_info"]:
            speed_info = result["speed_info"]
            total_preprocess += speed_info.get("preprocess_ms", 0)
            total_inference += speed_info.get("inference_ms", 0)
            total_postprocess += speed_info.get("postprocess_ms", 0)
            successful_images += 1

    # Calculate defect percentages
    defect_percentages = [
        {"name": CLASS_NAMES[class_id], "percentage": round((pcb_defect_counts[class_id] / total_images) * 100, 2)}
        for class_id in pcb_defect_counts
    ]

    # Good vs. Defective PCBs
    total_defective_pcbs = len([res for res in results if res.get("predictions")])
    defective_chart = [
        {"name": "Good PCBs", "value": max(0, total_images - total_defective_pcbs)},
        {"name": "Defective PCBs", "value": total_defective_pcbs}
    ]

    # Recent defects breakdown
    recent_defects = [
        {"pcb_id": f"PCB #{i+1}", "defects": [CLASS_NAMES[p["class_id"]] for p in res["predictions"]]}
        for i, res in enumerate(results) if "predictions" in res and res["predictions"]
    ]

    # Calculate average speed info if there are successful images
    avg_speed_info = {}
    if successful_images > 0:
        avg_speed_info = {
            "avg_preprocess_ms": round(total_preprocess / successful_images, 2),
            "avg_inference_ms": round(total_inference / successful_images, 2),
            "avg_postprocess_ms": round(total_postprocess / successful_images, 2)
        }

    return JSONResponse(content={
        "batch_results": results,
        "summary": {
            "defect_percentages": defect_percentages,
            "defective_chart": defective_chart,
            "recent_defects": recent_defects,
            "average_speed_info": avg_speed_info  # Include aggregated speed info for the batch
        }
    })

# Root API Test
@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI is working!"}

# Run FastAPI App
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
