"""
Specialized datasets and model architectures.

This directory contains:
- Pre-trained model architectures (BERT, ResNet)
- Training scripts for various ML tasks
- Framework-specific datasets (PyTorch, TensorFlow, React, etc.)
- Specialized datasets in parquet format
"""

__version__ = "1.0.0"

# Available architectures
AVAILABLE_ARCHITECTURES = [
    "bert_architecture",
    "resnet_architecture",
]

# Available training scripts
TRAINING_SCRIPTS = [
    "hf_classification_training",
    "hf_clm_training", 
    "hf_qa_training",
]
