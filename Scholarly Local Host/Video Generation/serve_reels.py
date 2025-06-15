import os
import urllib.parse
from flask import Flask, request, send_from_directory, abort, jsonify, send_file

app = Flask(__name__)

@app.route('/videos/<path:filename>') 
#Function to serve reels to the API
def serve_video(filename):
    decoded_filename = urllib.parse.unquote(filename)  # Decode URL
    file_directory = os.path.dirname(decoded_filename)
    file_name = os.path.basename(decoded_filename)
    file_path = os.path.join(file_directory, file_name)  # Full path

    if os.path.exists(file_path):
        return send_file(file_path, mimetype='video/mp4', as_attachment=False)
    else:
        return jsonify({"error": "File not found"}), 404


#Function to get the lists of videos
@app.route('/videos', methods=['POST'])
def list_videos():
    data = request.get_json()
    video_path = data.get('path')
    basic_url = data.get('url')

    if not video_path:
        return jsonify({"error": "Path is required"}), 400

    #Getting path of generated video
    full_path = os.path.join(video_path, 'reels')

    if not os.path.exists(full_path):
        return jsonify({"error": "Directory not found"}), 404

    video_files = [f for f in os.listdir(full_path) if f.endswith('.mp4')]
    #Generating URLs
    # video_urls = [f"http://192.168.100.38:5003/videos/{urllib.parse.quote(os.path.join(full_path, video))}" for video in video_files]
    video_urls = [f"{basic_url}:5003/videos/{urllib.parse.quote(os.path.join(full_path, video))}"for video in video_files]

    return jsonify({"videos": video_urls})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)
