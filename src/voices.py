import os
from huggingface_hub import HfApi

# Initialize the Hugging Face API client
api = HfApi()

print("Fetching available voices from the repository...")

# List all files inside the repository
repo_files = api.list_repo_files(repo_id="mlx-community/Kokoro-82M-bf16")

# Filter files that are inside the 'voices/' directory and extract their IDs
available_voices = []
for file_path in repo_files:
    if file_path.startswith("voices/"):
        # Extract filename (e.g., 'voices/af_heart.safetensors' -> 'af_heart')
        filename = os.path.basename(file_path)
        voice_id, ext = os.path.splitext(filename)

        # Avoid counting structural or duplicate files
        if voice_id and voice_id not in available_voices:
            available_voices.append(voice_id)

# Sort and display the results
available_voices.sort()
print(f"\nTotal available voices found: {len(available_voices)}\n")
for voice in available_voices:
    print(f"- {voice}")
