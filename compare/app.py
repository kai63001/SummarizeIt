from flask import Flask, request
from llmlingua import PromptCompressor

llm_lingua = PromptCompressor(
    model_name="microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank",
    device_map="cpu",
    use_llmlingua2=True
)
app = Flask('openai-quickstart-python')

@app.route("/")
def index():
    return "Hello, Flask!"

def split_text(text):
    max_chunk_size = 2048
    chunks = []
    current_chunk = ''

    for sentence in text.split('.'):
        if len(current_chunk) + len(sentence) < max_chunk_size:
            current_chunk += sentence + '.'
        else:
            chunks.append(current_chunk.strip())
            current_chunk = sentence + '.'

    if current_chunk:
        chunks.append(current_chunk.strip())

    return chunks

@app.route("/gpt", methods=["POST", "GET"])
def gpt():
    if request.method == "POST":
        data = request.get_json();

        if (data['data'] == None):
            return "Data is missing"
        
        results = llm_lingua.compress_prompt_llmlingua2(
            split_text(data['data']),
            rate=0.3,
            force_tokens=['\n', '.', '!', '?', ','],
            chunk_end_tokens=['.', '\n'],
            drop_consecutive=True,
        )
        # Process the JSON data
        return results
    elif request.method == "GET":
        # Process the GET request
        return "Received GET request"
    else:
        return "Invalid request method"

if __name__ == "__main__":
    app.run(port=8000, debug=True)

