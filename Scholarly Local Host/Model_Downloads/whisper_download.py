from transformers import WhisperProcessor, WhisperForConditionalGeneration

model_name = "openai/whisper-base"

# Define local directory to store the model
local_dir = "./whisper_model"

# Download and save the processor and model locally
processor = WhisperProcessor.from_pretrained(model_name)
processor.save_pretrained(local_dir)

model = WhisperForConditionalGeneration.from_pretrained(model_name)
model.save_pretrained(local_dir)

print(f"Model downloaded and saved in {local_dir}")