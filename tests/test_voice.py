# import os
# os.environ["HF_TOKEN"] = "your_actual_token_here"

from kokoro_mlx import KokoroTTS
import warnings
warnings.filterwarnings("ignore", category=FutureWarning)

KokoroTTS.from_pretrained().speak("Hello. This is a local text to speech test running on Apple Silicon.")

