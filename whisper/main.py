from flask import Flask, request
from faster_whisper import WhisperModel
from pytube import YouTube, Channel
import ssl
import pandas as pd
import os

app = Flask(__name__)
ssl._create_default_https_context = ssl._create_unverified_context

@app.route("/", methods=["GET"])
def index():
    return "Hello, Flask!"

def youtube_transcript_whisper(url):
    # Remove the audio file if it exists
    if os.path.exists("audio.mp4"):
        os.remove("audio.mp4")

    audio_file = YouTube(url).streams.filter(
        only_audio=True).first().download(filename="audio.mp4")

    print("audio file downloaded")

    model = WhisperModel("small", device="cpu", compute_type="int8")

    segments, info = model.transcribe(audio_file, beam_size=5)

    print("Detected language '%s' with probability %f" % (info.language, info.language_probability))

    for segment in segments:
        print("[%.2fs -> %.2fs] %s" % (segment.start, segment.end, segment.text))
    print("transcription done", segments)

    return ""


@app.route("/youtube_transcript", methods=["POST"])
def youtube_translate():
    data = request.get_json();
    if (data['url'] == None):
        return "url is missing"
    
    return youtube_transcript_whisper(data['url'])

if __name__ == "__main__":
    app.run(port=3001)

