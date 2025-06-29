# Speech Accessibility Challenge

The **Speech Accessibility Challenge 2025**, organized by the University of Illinois Chicago and hosted on [EvalAI](https://eval.ai/), aimed to advance inclusive automatic speech recognition (ASR) systems by encouraging research on speech data from individuals with dysarthria.

Participants were provided with the [UA Speech dataset](https://dialrcs.github.io/ua-speech-corpus/) and tasked with building robust ASR models capable of handling diverse speech patterns. We participated in the challenge and experimented with **four ASR models**:
- Whisper Base (fine-tuned using Parameter-Efficient Fine-Tuning (PEFT) with Low-Rank Adaptation (LoRA) on a CPU),
- Wav2Vec2 Base,
- Whisper Medium,
- HuBert CTC.

## Results

| Model             | WER (%) | SemScore |
|-------------------|---------|----------|
| Whisper Base LoRA |  32.11  |   71.72  |
| Wav2Vec2 Base     |  35.63  |   63.60  |
| Whisper Medium    |  36.29  |   61.78  |
| HuBert CTC        |  33.60  |   69.07  |


## Model Checkpoints

You can load the trained models directly from Hugging Face (https://huggingface.co/Sanjay180803/)

## Running the Project

This project sets up a virtual environment and runs a Python script for speech recognition tasks. The setup is automated via a Bash script (`run.sh`).

### Prerequisites

- Python 3.6 – 3.11
- pip (Python package installer)

### Steps

1. **Prepare Audio and Text**
   - Audio files should be in **16 kHz WAV** format.
   - Transcriptions should be in a **CSV** file.

2. **Run the Bash Script**
   - Open your terminal in the project directory.
   - Modify necessary changes in the "Paths to pass as arguments" sections of `run.sh`.
   - The same inference script and run.sh can be used for Wav2vec2 and HubertCPC.
   - Execute:
     ```bash
     bash run.sh
     ```

3. **Single File Inference**
   - An additional inference script (test.py) is provided in the repository to test predictions on single audio files.

---
