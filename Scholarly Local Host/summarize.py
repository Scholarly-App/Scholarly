import json
from flask import Flask, request, jsonify
from transformers import BartTokenizer, BartForConditionalGeneration
import torch
from transformers import pipeline

app = Flask(__name__)

# Load the locally saved model and tokenizer
model_path = "./bart_large_cnn_local"
tokenizer = BartTokenizer.from_pretrained(model_path)
model = BartForConditionalGeneration.from_pretrained(model_path)

#Function to summarize test
def summarize_text(text, max_chunk_size=1024):
    chunks = [text[i:i+max_chunk_size] for i in range(0, len(text), max_chunk_size)]
    summaries = []

    #Breaking text into chunks so accomodate max size
    for chunk in chunks:
        inputs = tokenizer(chunk, max_length=max_chunk_size, return_tensors="pt", truncation=True)
        with torch.no_grad():
            summary_ids = model.generate(
                inputs["input_ids"],
                max_length=200,
                min_length=50,
                length_penalty=2.0,
                num_beams=4,
                early_stopping=True
            )
        summaries.append(tokenizer.decode(summary_ids[0], skip_special_tokens=True))
    print(summaries)
    return " ".join(summaries)


@app.route('/summarize', methods=['POST'])
def summarize():
    data = request.get_json()
    text = data.get('text', '')  #get text from json object

    if not text:
        return jsonify({'error': 'No text provided'}), 400
    
    summary = summarize_text(text)
    return jsonify({'summary': summary})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)