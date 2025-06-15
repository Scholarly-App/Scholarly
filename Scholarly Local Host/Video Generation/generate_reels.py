from g4f.client import Client
import requests
import json
from pydub import AudioSegment
import random
from moviepy.editor import *
from math import ceil
from os import path, mkdir, system
from shutil import rmtree
import json
from sys import platform
import seewav
import tempfile
from pathlib import Path
from time import *
import re
import edge_tts
import asyncio
import whisper_timestamped as whisper
from whisper_timestamped import load_model, transcribe_timestamped
from flask import Flask, request, jsonify
import random
import shutil
import threading
from os import path, mkdir
from datetime import datetime
import spacy
import subprocess
import pytextrank
import nltk
from nltk.corpus import wordnet


PEXELS_API_KEY = os.getenv("PEXELS_API_KEY")
PEXELS_URL = "https://api.pexels.com/videos/search"

# Load the spaCy model
nlp = spacy.load("en_core_web_sm")
nlp.add_pipe("textrank")
nltk.download('wordnet')


app = Flask(__name__)

#Tech Keywords to fetch videos from Pexels
tech_keywords = [
    "Artificial Intelligence", "Machine Learning", "Holographic Displays", "Data Visualization",
    "Big Data", "Blockchain", "Decentralized Finance", "Bioinformatics", "Space Tech"
    "Cryptography", "Augmented Reality","Virtual Reality", "Edge Computing", "Authentication",
    "5G Technology", "Software Development", "Open Source", "Programming", "Data Structures",
    "Mobile Development", "Backend Development", "CSS", "HTML", "Digital Marketing",
    "Frontend Development","Intrusion Detection", "VPN", "Blockchain Security", "WiFi Security",
    "Smartphones", "Smartwatches", "Laptops", "Routers", "Data Engineering", "Data Mining",
    "Network Switches", "RAM", "SSD", "HDD", "Network Protocols", "Brain-Computer Interface",
    "Robotics", "IoT Devices", "Web 3.0", "AI in Business", "Genetic Algorithms",
    "Ethical Hacking", "Network Security", "Firewalls", "Reinforcement Learning", "PHP",
    "Progressive Web Apps",
    ]
    
#Non Tech Keywords to fetch videos from Pexels
non_tech_keywords = ['Accounting', 'Autobiography', 'Biography Writing', 'Narrative Techniques',
    'Blogging', 'Business Communication', 'Business Development', 'Business Ethics',
    'Business Law', 'Business Networking', 'Business_Strategy', "Children's Literature",
    'Content Writing', 'Contracts and Agreements','Cryptocurrency', 'Editing Techniques',
    'Freelance Writing', 'Investigative Journalism', 'Investment Banking', 'Literary Analysis',
    'Logistics', 'Manuscript Formatting', 'Mergers and Acquisitions', 'Metaphors and Similes',
    'Negotiation Skills', 'Persuasive Writing', 'Private Equity', 'Proofreading',
    'Risk Management', 'Startups', 'Stock Market', 'Study Techniques', 'Leadership',
    'Supply Chain Management', 'Sustainability in Business', 'Public_Relations', 'Remote_Work',
]


#Function to generate Voice Wave
def pfp_wave(buzz, timestamp, bg_m=1, fg=[1, 0.78, 0]):

    #Get the selected character
    buzz_list=['pictures/Ava.png', 'pictures/Clara.jpeg', 'pictures/Ryan.png', 'pictures/Connor.png']
    video_p = buzz_list[buzz-1]

    #Get the Wave motion
    # bg_list=[[0.21, 0.22, 0.24], [0.9058, 0.4352, 0.3176], [0.3960, 0.5058, 0.2784], [0.4549, 0.3176, 0.1764], [0.6745, 0.8823, 0.6862], [0.4549, 0.4117, 0.7137]]
    bg_list=[[0.21, 0.22, 0.24], [0.9058, 0.4352, 0.3176], [0.3960, 0.5058, 0.2784], [0.4549, 0.3176, 0.1764], [0.4549, 0.4117, 0.7137]]
    bg = bg_list[bg_m-1]

    #Generate Audio Wave video
    with tempfile.TemporaryDirectory() as tmp:
        seewav.visualize(audio=Path(f'tmp/tmp_{timestamp}/output.mp3'),
                        tmp=Path(tmp),
                        out=Path(f"tmp/tmp_{timestamp}/waves.mp4"),
                        fg_color=fg,
                        bg_color=bg,
                        size=(480, 480),
                        bars=70
                        )


    video= VideoFileClip(f"tmp/tmp_{timestamp}/waves.mp4")
    video_duration = video.duration
    x_pos = 20
    y_pos = 'center'

    title = (
        ImageClip(video_p)
        .set_pos((x_pos, y_pos))
        .resize(height=150)
    )
    final = CompositeVideoClip([video.set_duration(video_duration), title.set_duration(video_duration)])
    return final


#Function to merge both clips
def v_merger(clip1, clip2):
    #split screen two videos
    final = clips_array([[clip1], [clip2]])
    return final


#Fuction to mix audios and timestamps
def a_mixer(num,timestamp):

    #mixes base audio with a background music
    au_paths = ["Minecraft", "Subwoofer_Lullaby", "Moog_City_2"]
    if 1 <= num <= len(au_paths):
        au_path = au_paths[num - 1]
    else:
        au_path = None

    #Get both Sounds (Bg Music and Audio)
    sound1 = AudioSegment.from_file(f"music/{au_path}.mp3", format="mp3")
    sound2 = AudioSegment.from_file(f"tmp/tmp_{timestamp}/output.mp3", format="mp3")

    #Overlay both the sounds
    overlay = sound2.overlay(sound1, position=0)
    overlay.export(f"tmp/tmp_{timestamp}/F_output.mp3", format="mp3")
    return AudioFileClip(f"tmp/tmp_{timestamp}/F_output.mp3")



#Function to generate Background Gameplay videos
def backdrop(buzz,timestamp):

    #subclips the gameplay video according to the playtime of the audio
    video_paths = [
        'backdrop/minecraft.mp4',
        'backdrop/fh5.mp4',
        'backdrop/gtav.mp4',
        'backdrop/trackmania.mp4',
        f'tmp/tmp_{timestamp}/vid.mp4'
    ]

    if 1 <= buzz <= len(video_paths):
        video_path = video_paths[buzz - 1]
    else:
        video_path = None

    #Adjust Video Duration according to audio
    def vid_dur(file_path,timestamp):
       TempClip= VideoFileClip(file_path)
       vid_duration=TempClip.duration
       return vid_duration

    audio_duration = AudioSegment.from_file(f'tmp/tmp_{timestamp}/output.mp3').duration_seconds
    video_duration = vid_dur(video_path,timestamp)

    s_time = random.randint(0,ceil(video_duration-(audio_duration + 5)))
    e_time = s_time+ ceil(audio_duration)
    video= VideoFileClip(video_path).subclip(s_time,e_time)
    return video


#Function to append subtitles
def sub_append(font_no, color,timestamp,id,path,i):

    weight=16
    fonts = [
        {"name": "VT323", "weight": 20},
        {"name": "Jersey 10", "weight": 18},
        {"name": "Permanant Marker","weight": 18},
        {"name": "Archivo Black","weight": 14},
        {"name": "Bebas Neue","weight": 18}
    ]

    #Set the Font type and Weight
    if 1 <= font_no <= len(fonts):
        font_data = fonts[font_no - 1]
        font = font_data["name"]
        weight = font_data.get("weight", None)
    else:
        font = None
        weight = None

    #Set the Font Color
    color_list = ["&H0099ff", "&H0CC616", "&H2412E8", "&HF5A604"]
    color_code = color_list[color-1]

    #add subtitle
    time_tup = localtime()
    time_string = strftime("%d_%m_%Y__%H%M%S", time_tup)

    #Generate the Subtitles according to font, weight and color
    system(f"ffmpeg -hide_banner -loglevel error -i tmp/tmp_{timestamp}/subs.srt tmp/tmp_{timestamp}/subtitle.ass")
    ass_file_path = f'tmp/tmp_{timestamp}/subtitle.ass'
    new_style_definition = f'Style: Default,{font},{weight},{color_code},&Hffffff,&H0,&H0,1,0,0,0,100,100,0,0,1,1,2,5,50,50,50,1\n'

    with open(ass_file_path, 'r', encoding='utf-8') as file:
         lines = file.readlines()

    for line in lines:
        if line.strip().startswith('Style:'):
            lines[(lines.index(line))]=new_style_definition
    with open(f'tmp/tmp_{timestamp}/subtitle.ass', 'w') as file:
        file.write(''.join(lines))

    #Save the subtitles
    save_path = f'{path}/reels'
    os.makedirs(save_path, exist_ok=True)

    save_path = f'{path}/reels/{i}.mp4'
    os.system(f'ffmpeg -hide_banner -loglevel error -i tmp/tmp_{timestamp}/temporary.mp4 -vf "ass=tmp/tmp_{timestamp}/subtitle.ass" -c:a copy -c:v libx264 -crf 23 -preset veryfast \"{save_path}\"')



#Function to add audio
def add_aud(videoclip, audioclip,timestamp):
    #adds audio to the given video
    new_audioclip = CompositeAudioClip([audioclip])
    videoclip.audio = new_audioclip
    videoclip.write_videofile(f"tmp/tmp_{timestamp}/temporary.mp4", codec='libx264', audio_codec='aac')


#Function to generate audio given the selected character
async def generate_audio(text, character, output_filename):

    char_list=["en-CA-ClaraNeural", "en-US-AvaMultilingualNeural", "en-GB-RyanNeural", "en-IE-ConnorNeural"]
    voice = char_list[character-1]

    #Generate Audio using Edge TTS
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(output_filename)


#Function to generate Timed Caption using Whisper Model
def generate_timed_captions(audio_filename, model_size="base"):

    model_path = r"C:\Users\UmairKhalid\Desktop\Code\Scholarly Local Host\Video Generation"
    # Load Whisper model from the custom directory
    WHISPER_MODEL = whisper.load_model(model_size, download_root=model_path)
    gen = transcribe_timestamped(WHISPER_MODEL, audio_filename, verbose=False, fp16=False)
    return getCaptionsWithTime(gen)


#Function to split words according to generated captions
def splitWordsBySize(words, maxCaptionSize):
   
    halfCaptionSize = maxCaptionSize / 2
    captions = []
    while words:
        caption = words[0]
        words = words[1:]
        while words and len(caption + ' ' + words[0]) <= maxCaptionSize:
            caption += ' ' + words[0]
            words = words[1:]
            if len(caption) >= halfCaptionSize and words:
                break
        captions.append(caption)
    return captions


#Mapping the timestamps on words
def getTimestampMapping(whisper_analysis):
   
    index = 0
    locationToTimestamp = {}
    for segment in whisper_analysis['segments']:
        for word in segment['words']:
            newIndex = index + len(word['text'])+1
            locationToTimestamp[(index, newIndex)] = word['end']
            index = newIndex
    return locationToTimestamp


#Function to clean text
def cleanWord(word):
   
    return re.sub(r'[^\w\s\-_"\'\']', '', word)


#Return time according to words
def interpolateTimeFromDict(word_position, d):
   
    for key, value in d.items():
        if key[0] <= word_position <= key[1]:
            return value
    return None


#Function to generate and return timecaptions according to time
def getCaptionsWithTime(whisper_analysis, maxCaptionSize=15, considerPunctuation=False):
   
    wordLocationToTime = getTimestampMapping(whisper_analysis)
    position = 0
    start_time = 0
    CaptionsPairs = []
    text = whisper_analysis['text']
    
    if considerPunctuation:
        sentences = re.split(r'(?<=[.!?]) +', text)
        words = [word for sentence in sentences for word in splitWordsBySize(sentence.split(), maxCaptionSize)]
    else:
        words = text.split()
        words = [cleanWord(word) for word in splitWordsBySize(words, maxCaptionSize)]
    
    for word in words:
        position += len(word) + 1
        end_time = interpolateTimeFromDict(position, wordLocationToTime)
        if end_time and word:
            CaptionsPairs.append(((start_time, end_time), word))
            start_time = end_time

    return CaptionsPairs


#Function to convert JSON to Timestamps
def json_to_srt(captions, srt_file_path):
    with open(srt_file_path, 'w') as srt_file:
        index = 1
        for (start, end), text in captions:
            start_time = f"00:00:{start:06.3f}".replace('.', ',')
            end_time = f"00:00:{end:06.3f}".replace('.', ',')

            srt_file.write(f"{index}\n{start_time} --> {end_time}\n{text}\n\n")
            index += 1


#Function to split script
def split_script(script, chunk_size=200):
    """Splits the script into chunks of `chunk_size` words."""
    words = script.split()
    return [" ".join(words[i:i+chunk_size]) for i in range(0, len(words), chunk_size)]


def split_script(script, chunk_size=200):
    """Splits the script into chunks of `chunk_size` words."""
    words = script.split()
    return [" ".join(words[i:i+chunk_size]) for i in range(0, len(words), chunk_size)]

# Function to fetch videos
def fetch_videos(keyword, num_videos=1):
    headers = {"Authorization": PEXELS_API_KEY}
    params = {"query": keyword, "per_page": num_videos}
    response = requests.get(PEXELS_URL, headers=headers, params=params)
    if response.status_code == 200:
        videos = response.json().get("videos", [])
        return [video["video_files"][0]["link"] for video in videos]
    return []

# Function to download videos
def download_video(url, filename,timestamp):
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(f"tmp/tmp_{timestamp}/videos/{filename}", "wb") as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)

# Function to process videos: crop, trim to 10s, and ensure consistent timestamps
def process_video(input_path, output_path):
    command = [
        "ffmpeg",
        "-i", input_path,
        "-t", "10",  # Trim to 10s
        "-vf", "crop=in_h*9/16:in_h:(in_w-out_w)/2:0,scale=720:1280",  # Crop to 9:16
        "-c:v", "libx264", "-preset", "fast", "-crf", "23",
        "-r", "30",  # Force frame rate to prevent timestamp issues
        "-c:a", "aac", "-b:a", "128k",
        "-y", output_path
    ]
    try:
        subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)  # Suppress output
    except subprocess.CalledProcessError as e:
        print(f"Error processing {input_path}: {e}")


# Function to concatenate videos properly
def concatenate_videos(video_list, output_path):
    list_file = "file_list.txt"
    with open(list_file, "w") as f:
        for video in video_list:
            f.write(f"file '{video}'\n")

    command = [
        "ffmpeg",
        "-f", "concat",
        "-safe", "0",
        "-i", list_file,
        "-c:v", "libx264", "-crf", "23", "-preset", "fast",
        "-r", "30",  # Enforce 30 FPS
        "-c:a", "aac", "-b:a", "128k",
        "-y", output_path
    ]

    try:
        subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)  # Suppress output
        print(f"Final video created: {output_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error concatenating videos: {e}")
    # subprocess.run(command, check=True)
    # print(f"Final video created: {output_path}")

# Function to delete temporary files
def cleanup_temp_files():
    try:
        shutil.rmtree("tmp/videos")  # Delete the videos folder
        shutil.rmtree("tmp/processed_videos")  # Delete the processed videos folder
        print("Temporary files deleted successfully!")
    except Exception as e:
        print(f"Error deleting temporary files: {e}")

# Function to check if all words in a phrase are valid English words
def is_valid_phrase(phrase):
    words = phrase.split()

    # Reject non-alphabetic phrases
    if not re.match(r'^[A-Za-z\s\-]+$', phrase):
        return False

    # Ensure all words in the phrase are valid English words
    return all(wordnet.synsets(word) for word in words)

# Function to lemmatize a phrase
def lemmatize_phrase(phrase):
    doc = nlp(phrase)
    return " ".join([token.lemma_ for token in doc])


def process_reel(data):
    """Background task to generate reels after sending response."""
    script = data.get('script')
    
    # Predefined lists
    id = data.get('id')
    path = data.get('path')
    char_list = ['Ava', 'Clara', 'Ryan', 'Connor']
    font_list = ['VT323', 'Jersey 10', 'Archivo Black', 'Bebas Neue']
    font_color_list = ['Orange', 'Green', 'Red', 'Blue']
    bg_color_list = ['Grey', 'Tangerine', 'Sap Green', 'Brown', 'Soft Purple']
    type_list = ['Regular', 'Meme']

    # Get indexes
    char_index = char_list.index(data.get('character')) if data.get('character') in char_list else 1 
    font_index = font_list.index(data.get('font')) if data.get('font') in font_list else 1
    text_color_index = font_color_list.index(data.get('text_color')) if data.get('text_color') in font_color_list else 1
    bg_color_index = bg_color_list.index(data.get('background_color')) if data.get('background_color') in bg_color_list else 1
    type_index = type_list.index(data.get('type')) if data.get('type') in type_list else 1
    
    print("Indexes Fetched")  # Response is sent immediately after this line
    
    # Split script into 200-word chunks
    script_chunks = split_script(script, 200)
    
    for i, chunk in enumerate(script_chunks):
            
        
        # Generate a timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        # Create the directory with the timestamp
        dir_name = f"tmp/tmp_{timestamp}"
        os.makedirs(dir_name, exist_ok=True)

        print(f"\n[*] Processing Chunk {i+1}/{len(script_chunks)}")
        
        # Generate audio
        audio_file = f"tmp/tmp_{timestamp}/output.mp3"
        asyncio.run(generate_audio(chunk, char_index+1, audio_file))
        
        # Generate subtitles
        captions = generate_timed_captions(audio_file)
        subtitle_file = f"tmp/tmp_{timestamp}/subs.srt"
        json_to_srt(captions, subtitle_file)
        print("[*] Subtitles Generated")

        if(type_index == 0):

            # text = chunk
            # doc = nlp(text)
            # valid_phrases = []
            # index = 0
            # used_lemmas = set()

            # while len(valid_phrases) < 15 and index < len(doc._.phrases):
            #     phrase = doc._.phrases[index].text.strip().lower()
            #     position = text.lower().find(phrase)  # Get position in original text

            #     lemmatized_phrase = lemmatize_phrase(phrase)

            #     phrase_lemmas = {lemma for lemma in lemmatized_phrase.split() if len(lemma) > 3}

            #     # Check if phrase is valid and if it shares lemmas with existing phrases
            #     if is_valid_phrase(phrase) and not phrase_lemmas.intersection(used_lemmas):
            #         valid_phrases.append((phrase, position))  # Store phrase with its position
            #         used_lemmas.update(phrase_lemmas)  # Add lemmas to the used lemmas set

            #     index += 1

            # # Sort valid phrases based on appearance order in the text
            # sorted_valid_phrases = [phrase for phrase, _ in sorted(valid_phrases, key=lambda x: x[1])]

            # if len(sorted_valid_phrases) < 15:
            #     index = 0
            #     while len(sorted_valid_phrases) < 15:
            #         sorted_valid_phrases.append(sorted_valid_phrases[index % len(sorted_valid_phrases)])
            #         index += 1
            
            text = chunk
            keywords = random.sample(tech_keywords, 11)
            video_results = {keyword: fetch_videos(keyword, num_videos=1) for keyword in keywords}

            # Create directories
            os.makedirs(f"tmp/tmp_{timestamp}/videos", exist_ok=True)
            os.makedirs(f"tmp/tmp_{timestamp}/processed_videos", exist_ok=True)

            # Download videos
            video_files = []
            for idx, (keyword, videos) in enumerate(video_results.items()):
                if videos:
                    filename = f"video_{idx}.mp4"
                    download_video(videos[0], filename,timestamp)
                    video_files.append(f"tmp/tmp_{timestamp}/videos/{filename}")

            print(f"Videos Downloaded")

            # Process videos
            processed_video_files = []
            for file in video_files:
                output_path = f"tmp/tmp_{timestamp}/processed_videos/processed_{os.path.basename(file)}"
                process_video(file, output_path)
                processed_video_files.append(output_path)

            print("All videos processed successfully!")

            # Generate final video
            
            final_video_path = f"tmp/tmp_{timestamp}/vid.mp4"
            concatenate_videos(processed_video_files, final_video_path)

            # Call cleanup function
            # cleanup_temp_files()

            vid = backdrop(5,timestamp)
            random_number = random.randint(1, 3)
            a_mixed = a_mixer(random_number,timestamp)
            print("[*] Mixing Audio")
            add_aud(vid, a_mixed,timestamp)

            # Add subtitles
            sub_append(font_index+1, text_color_index+1,timestamp,id,path,i)
            
            # Save the generated video file
            video_file = f"tmp/tmp_{timestamp}/video_{i}.mp4"
            print(f"[*] Video Chunk {i+1} Generated")
            

        else:
            # Generate visuals
            random_number = random.randint(1, 4)
            bckdrp = backdrop(random_number,timestamp)
            pwave = pfp_wave(char_index+1, timestamp, bg_color_index+1)
            print("[*] Background Video Generated")

            # Mix audio
            random_number = random.randint(1, 3)
            a_mixed = a_mixer(random_number,timestamp)
            merg = v_merger(pwave, bckdrp)
            print("[*] Mixing Audio")
            add_aud(merg, a_mixed,timestamp)

            # Add subtitles
            sub_append(font_index+1, text_color_index+1,timestamp,id,path,i)
            
            # Save the generated video file
            video_file = f"tmp/tmp_{timestamp}/video_{i}.mp4"
            print(f"[*] Video Chunk {i+1} Generated")

    print("\n[*] All Video Chunks Generated")


@app.route('/generate_reels', methods=['POST'])
def generate_reel():
    
    #Cleanup temp files
    if path.exists("tmp"):
        shutil.rmtree("tmp")
        mkdir("tmp")
    else:
        mkdir("tmp")

    data = request.json
    
    # Start background processing in a separate thread
    threading.Thread(target=process_reel, args=(data,)).start()
    
    # Return response immediately after "Indexes Fetched"
    return jsonify({
        "message": "Reel data received successfully, processing will continue in the background"
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)