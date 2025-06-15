from huggingface_hub import snapshot_download

# Download the entire model to a local folder
model_path = "./sd3.5_medium"  # Change this to your preferred path
snapshot_download(repo_id="stabilityai/stable-diffusion-3.5-medium", local_dir=model_path)
