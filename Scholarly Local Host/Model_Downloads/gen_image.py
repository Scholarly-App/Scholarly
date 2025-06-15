from diffusers import DiffusionPipeline

# Path to your locally saved model
model_path = "C:\\Users\\UmairKhalid\\Desktop\\Code\\Scholarly Local Host\\sd3.5_medium"

# Load the pipeline from local directory
pipe = DiffusionPipeline.from_pretrained(model_path)

# Define prompt and image size
prompt = "Astronaut in a jungle, cold color palette, muted colors, detailed, 8k"
width = 768
height = 1024

# Generate image using the local model
image = pipe(prompt, width=width, height=height).images[0]

# Save and display the image
image.save("generated_image.png")
image.show()
