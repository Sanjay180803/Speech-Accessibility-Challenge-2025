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

# Define paths
root=/taiga/downloads/${team_name}/${submission_pk}
PYTHON_ENVIRONMENT=${team_name}

# Model and script paths
MODEL_PATH="${root}/wav2vec2-finetuned_new12"  # Model path
SCRIPT="${root}/inference.py"                  # Python script
OUTPUT_DIR="${root}/inference"                 # Output directory

# Dataset paths and expected lengths
splits='test1 test2'
metadata_base_path="/taiga/manifest"
len_test1=7601
len_test2=8043

source ~/.bashrc
source ~/miniconda3/etc/profile.d/conda.sh

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

    echo "Creating Conda environment ${PYTHON_ENVIRONMENT}..."
    conda create --name ${PYTHON_ENVIRONMENT} python=3.12 --yes
fi

conda activate ${PYTHON_ENVIRONMENT}

# Stage 1: Installing dependencies
if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
    echo "Stage 1: Installing dependencies..."

    echo "Upgrading pip..."
    pip install --upgrade pip

    echo "Installing required packages..."
    pip install transformers torch torchaudio pandas tqdm
fi

# Stage 2: Running inference
if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
    echo "Stage 2: Running inference..."

    mkdir -p ${OUTPUT_DIR}

    for split in ${splits}; do
        output_file="${OUTPUT_DIR}/${split}.hypo"
        metadata_file="${metadata_base_path}/${split}.tsv"
        output_len_var="len_${split}"

        if [ -e "${output_file}" ] && [ "$(wc -l < "${output_file}")" -eq "${!output_len_var}" ]; then
            echo "File ${output_file} already exists and has the correct length. Skipping inference..."
        else
            python $SCRIPT \
                --metadata_path "$metadata_file" \
                --model_path "$MODEL_PATH" \
                --output_path "$output_file"
        fi
    done

    conda deactivate
fi

# Stage 3: Post-processing or Evaluation (if needed)
if [ $stage -le 3 ] && [ $stop_stage -ge 3 ]; then
    echo "Stage 3: Post-processing or Evaluation..."
    # Additional commands can go here
fi
