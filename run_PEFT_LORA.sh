#!/bin/bash

# Exit on any error
set -e

# ---------------------------
# Configuration Parameters
# ---------------------------

# Define the stages to execute
stage=0
stop_stage=3

# Accept team name and submission primary key as arguments
team_name=$1
submission_pk=$2

source ~/.bashrc
source ~/miniconda3/etc/profile.d/conda.sh
PYTHON_ENVIRONMENT=${team_name}
root=/taiga/downloads/${team_name}/${submission_pk}

# Python version to use
python_version=3.12  # Update with your required Python version

# Paths to pass as arguments
MODEL_PATH="${root}/whisper_base_model"              # Path to the Whisper model
ADAPTER_PATH="${root}/whisper-lora-finetuned"        # Path to the LoRA adapter
SCRIPT="${root}/inference.py"                        # Python script to run

# ---------------------------
# Stage Definitions
# ---------------------------

# Stage 0: Setting up Conda environment
if [ $stage -le 0 ] && [ $stop_stage -ge 0 ]; then
    echo "Stage 0: Setting up Conda environment..."

    if conda info --envs | grep -q "^${PYTHON_ENVIRONMENT}"; then
        echo "Environment ${PYTHON_ENVIRONMENT} already exists. Removing it..."
        conda remove --name ${PYTHON_ENVIRONMENT} --all --yes
    fi

    echo "Creating Conda environment ${PYTHON_ENVIRONMENT} with Python ${python_version}..."
    conda create --name ${PYTHON_ENVIRONMENT} python=${python_version} --yes
fi

conda activate ${PYTHON_ENVIRONMENT}

# Stage 1: Installing dependencies
if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
    echo "Stage 1: Installing dependencies..."

    # Upgrade pip
    echo "Upgrading pip..."
    pip install --upgrade pip

    # Install required Python packages
    echo "Installing required packages..."
    pip install transformers peft torch librosa pandas jiwer numpy
fi

# Stage 2: Running inference
if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
    echo "Stage 2: Running inference..."

    splits='test1 test2'
    output_pth=${root}/inference
    mkdir -p ${output_pth}

    len_test1=7601
    len_test2=8043
    
    for split in ${splits}; do
        output_name=${output_pth}/${split}.hypo
        output_len="len_${split}"
        metadata_path="/taiga/manifest/${split}.tsv"
        
        if [ -e "${output_name}" ] && [ "$(wc -l < "$output_name")" -eq "${!output_len}" ]; then
            echo "File already exists, skipping model inference..."
        else
            python $SCRIPT \
                --metadata_path "$metadata_path" \
                --model_path "$MODEL_PATH" \
                --adapter_path "$ADAPTER_PATH" \
                --output_path "${output_name}"
        fi
    done

    conda deactivate
fi

# Stage 3: Post-processing or Evaluation
if [ $stage -le 3 ] && [ $stop_stage -ge 3 ]; then
    echo "Stage 3: Post-processing or Evaluation..."

    PYTHON_ENVIRONMENT=evaluate
    conda activate ${PYTHON_ENVIRONMENT}

    # Ensure the evaluation script path is defined
    EVALUATE_SCRIPT="/taiga/utils/evaluate.py"

    if [ -f "$EVALUATE_SCRIPT" ]; then
        echo "Executing ${EVALUATE_SCRIPT}..."
        python3 $EVALUATE_SCRIPT \
            --submission-team-name ${team_name} \
            --submission-pk ${submission_pk}
    else
        echo "Warning: ${EVALUATE_SCRIPT} not found. Skipping evaluation."
    fi

    echo "Deactivating Conda environment..."
    conda deactivate
fi

