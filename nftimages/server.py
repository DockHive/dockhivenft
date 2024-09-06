from flask import Flask, send_file, abort , jsonify
import os

app = Flask(__name__)


NFT_METADATA = {
    1: {"name": "Token One", "description": "This is the first token", "image": "https://example.com/path/to/image1.png"},
    2: {"name": "Token Two", "description": "This is the second token", "image": "https://example.com/path/to/image2.png"},
    # Add more token data as needed
}

@app.route('/nft-image/<int:token_id>')
def nft_image(token_id):
    # Define the path to your images directory
    image_directory = 'path/to/your/images'
    # Construct the file path based on token_id
    image_path = os.path.join(image_directory, f'{token_id}.png')

    # Check if the image file exists
    if os.path.exists(image_path):
        return send_file(image_path, mimetype='image/png')
    else:
        abort(404, description="Image not found")



@app.route('/nft-metadata/<int:token_id>')
def nft_metadata(token_id):
    # Fetch metadata for the given token_id
    metadata = NFT_METADATA.get(token_id)

    if metadata:
        return jsonify(metadata)
    else:
        abort(404, description="Metadata not found")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
