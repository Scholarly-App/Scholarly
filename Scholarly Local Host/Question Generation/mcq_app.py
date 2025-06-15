from flask import Flask, request, jsonify
from app.mcq_generation import MCQGenerator
import random
import os
import requests

app = Flask(__name__)
# app.config['SECRET_KEY'] = 'pass'

MCQ_Generator = MCQGenerator(True)


#Function to generate Quiz
@app.route('/generate', methods=['GET', 'POST'])
def index():
    data = request.json
    #Get the text and question count
    text = data.get('text')
    num = int(data.get('count'))
    
    formatted_questions = []
    #Generate MCQ Question using MCQ Generator
    questions = MCQ_Generator.generate_mcq_questions(text, num)[0:num]
    for question in questions:
        #For every question generate the distractors
        question.distractors.append(question.answerText)
        random.shuffle(question.distractors)

        #Format into a JSON and return generated Questions
        formatted_questions.append({
            "question": question.questionText,
            "answer": question.answerText,
            "options": question.distractors
        })
    return jsonify({"questions": formatted_questions}) 


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004, debug=True)
