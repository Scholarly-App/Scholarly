from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

# Define the model name
model_name = "facebook/bart-large-cnn"

# Load the tokenizer and model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)

# Define the save path
save_path = "./bart_large_cnn_local"

# Save the model and tokenizer
tokenizer.save_pretrained(save_path)
model.save_pretrained(save_path)

print(f"Model and tokenizer saved to {save_path}")