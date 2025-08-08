#!/usr/bin/env python3
"""
🌐 نظام التدريب السحابي المتقدم
دعم Google Colab, Kaggle, والحلول السحابية الأخرى
"""

import os
import json
import subprocess
import zipfile
from pathlib import Path
import requests

class CloudTrainingSetup:
    """إعداد التدريب السحابي"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.cloud_folder = self.project_root / "cloud_training"
        self.cloud_folder.mkdir(exist_ok=True)
    
    def create_colab_notebook(self, config: dict = None):
        """إنشاء Google Colab Notebook للتدريب"""
        print("📚 إنشاء Google Colab Notebook...")
        
        if config is None:
            config = {
                "model_name": "microsoft/DialoGPT-medium",
                "epochs": 3,
                "batch_size": 8,  # أكبر للـ GPU
                "learning_rate": 5e-5,
                "max_length": 512
            }
        
        notebook_content = {
            "cells": [
                {
                    "cell_type": "markdown",
                    "metadata": {},
                    "source": [
                        "# 🔥 Fine-Tuning AI - التدريب السحابي المتقدم\n",
                        "## نظام تدريب نماذج الذكاء الاصطناعي باستخدام Google Colab\n",
                        "\n",
                        "### المميزات:\n",
                        "- 🚀 GPU مجاني من Google\n",
                        "- 💾 ذاكرة كبيرة (12GB GPU RAM)\n",
                        "- ⚡ تدريب سريع ومتقدم\n",
                        "- 🔄 تحديث تلقائي للتقدم"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 📦 تثبيت المكتبات المطلوبة\n",
                        "!pip install torch torchvision torchaudio\n",
                        "!pip install transformers datasets tokenizers accelerate\n",
                        "!pip install pandas numpy tqdm matplotlib seaborn\n",
                        "!pip install google-colab-utils\n",
                        "\n",
                        "# 🔍 فحص GPU\n",
                        "import torch\n",
                        "print(f\"🚀 CUDA متاح: {torch.cuda.is_available()}\")\n",
                        "if torch.cuda.is_available():\n",
                        "    print(f\"💻 GPU: {torch.cuda.get_device_name(0)}\")\n",
                        "    print(f\"💾 ذاكرة GPU: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 📂 رفع البيانات من Google Drive\n",
                        "from google.colab import drive\n",
                        "drive.mount('/content/drive')\n",
                        "\n",
                        "# أو رفع ملف ZIP\n",
                        "from google.colab import files\n",
                        "print(\"📤 ارفع ملف البيانات (ZIP):\")\n",
                        "uploaded = files.upload()\n",
                        "\n",
                        "# استخراج البيانات\n",
                        "import zipfile\n",
                        "for filename in uploaded.keys():\n",
                        "    with zipfile.ZipFile(filename, 'r') as zip_ref:\n",
                        "        zip_ref.extractall('/content/training_data')\n",
                        "    print(f\"✅ تم استخراج {filename}\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        f"# ⚙️ إعدادات التدريب\n",
                        f"CONFIG = {json.dumps(config, indent=2, ensure_ascii=False)}\n",
                        "\n",
                        "print(\"🔧 إعدادات التدريب:\")\n",
                        "for key, value in CONFIG.items():\n",
                        "    print(f\"  {key}: {value}\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 🤖 نظام التدريب المتقدم\n",
                        "import json\n",
                        "import torch\n",
                        "import pandas as pd\n",
                        "from pathlib import Path\n",
                        "from transformers import (\n",
                        "    AutoTokenizer, AutoModelForCausalLM,\n",
                        "    TrainingArguments, Trainer,\n",
                        "    DataCollatorForLanguageModeling\n",
                        ")\n",
                        "from datasets import Dataset\n",
                        "import logging\n",
                        "from tqdm.auto import tqdm\n",
                        "import matplotlib.pyplot as plt\n",
                        "import time\n",
                        "\n",
                        "class ColabTrainer:\n",
                        "    def __init__(self, config):\n",
                        "        self.config = config\n",
                        "        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'\n",
                        "        print(f\"🚀 التدريب على: {self.device}\")\n",
                        "    \n",
                        "    def load_data(self, data_path='/content/training_data'):\n",
                        "        \"\"\"تحميل البيانات\"\"\"\n",
                        "        print(\"📊 تحميل البيانات...\")\n",
                        "        \n",
                        "        data_path = Path(data_path)\n",
                        "        all_texts = []\n",
                        "        \n",
                        "        # قراءة ملفات JSON\n",
                        "        json_files = list(data_path.rglob('*.json'))\n",
                        "        print(f\"📁 عثر على {len(json_files)} ملف JSON\")\n",
                        "        \n",
                        "        for file_path in tqdm(json_files[:50], desc=\"معالجة الملفات\"):\n",
                        "            try:\n",
                        "                with open(file_path, 'r', encoding='utf-8') as f:\n",
                        "                    data = json.load(f)\n",
                        "                \n",
                        "                if isinstance(data, list):\n",
                        "                    for item in data:\n",
                        "                        text = self._extract_text(item)\n",
                        "                        if text and len(text) > 10:\n",
                        "                            all_texts.append(text)\n",
                        "                elif isinstance(data, dict):\n",
                        "                    text = self._extract_text(data)\n",
                        "                    if text and len(text) > 10:\n",
                        "                        all_texts.append(text)\n",
                        "                        \n",
                        "            except Exception as e:\n",
                        "                print(f\"⚠️ خطأ في {file_path}: {e}\")\n",
                        "        \n",
                        "        print(f\"✅ تم تحميل {len(all_texts):,} نص\")\n",
                        "        return Dataset.from_dict({'text': all_texts})\n",
                        "    \n",
                        "    def _extract_text(self, item):\n",
                        "        \"\"\"استخراج النص\"\"\"\n",
                        "        if isinstance(item, str):\n",
                        "            return item\n",
                        "        \n",
                        "        text_fields = ['text', 'content', 'source', 'code', 'prompt', 'response']\n",
                        "        for field in text_fields:\n",
                        "            if isinstance(item, dict) and field in item:\n",
                        "                if isinstance(item[field], str):\n",
                        "                    return item[field]\n",
                        "                elif isinstance(item[field], list):\n",
                        "                    return ''.join(item[field])\n",
                        "        \n",
                        "        return str(item) if item else None\n",
                        "    \n",
                        "    def prepare_model_and_tokenizer(self):\n",
                        "        \"\"\"تحضير النموذج والمُرمز\"\"\"\n",
                        "        print(f\"🤖 تحميل النموذج: {self.config['model_name']}\")\n",
                        "        \n",
                        "        self.tokenizer = AutoTokenizer.from_pretrained(self.config['model_name'])\n",
                        "        if self.tokenizer.pad_token is None:\n",
                        "            self.tokenizer.pad_token = self.tokenizer.eos_token\n",
                        "        \n",
                        "        self.model = AutoModelForCausalLM.from_pretrained(\n",
                        "            self.config['model_name'],\n",
                        "            torch_dtype=torch.float16,\n",
                        "            device_map='auto'\n",
                        "        )\n",
                        "        \n",
                        "        print(f\"✅ تم تحميل النموذج على {next(self.model.parameters()).device}\")\n",
                        "    \n",
                        "    def tokenize_dataset(self, dataset):\n",
                        "        \"\"\"ترميز البيانات\"\"\"\n",
                        "        print(\"🔤 ترميز البيانات...\")\n",
                        "        \n",
                        "        def tokenize_function(examples):\n",
                        "            return self.tokenizer(\n",
                        "                examples['text'],\n",
                        "                truncation=True,\n",
                        "                padding=True,\n",
                        "                max_length=self.config['max_length'],\n",
                        "                return_tensors='pt'\n",
                        "            )\n",
                        "        \n",
                        "        tokenized = dataset.map(\n",
                        "            tokenize_function,\n",
                        "            batched=True,\n",
                        "            remove_columns=dataset.column_names\n",
                        "        )\n",
                        "        \n",
                        "        print(f\"✅ تم ترميز {len(tokenized)} عينة\")\n",
                        "        return tokenized\n",
                        "    \n",
                        "    def train_model(self, tokenized_dataset):\n",
                        "        \"\"\"تدريب النموذج\"\"\"\n",
                        "        print(\"🔥 بدء التدريب...\")\n",
                        "        \n",
                        "        training_args = TrainingArguments(\n",
                        "            output_dir='/content/fine_tuned_model',\n",
                        "            num_train_epochs=self.config['epochs'],\n",
                        "            per_device_train_batch_size=self.config['batch_size'],\n",
                        "            gradient_accumulation_steps=2,\n",
                        "            warmup_steps=500,\n",
                        "            learning_rate=self.config['learning_rate'],\n",
                        "            fp16=True,\n",
                        "            logging_steps=50,\n",
                        "            save_steps=1000,\n",
                        "            save_total_limit=2,\n",
                        "            dataloader_pin_memory=False,\n",
                        "            report_to=None\n",
                        "        )\n",
                        "        \n",
                        "        data_collator = DataCollatorForLanguageModeling(\n",
                        "            tokenizer=self.tokenizer,\n",
                        "            mlm=False\n",
                        "        )\n",
                        "        \n",
                        "        trainer = Trainer(\n",
                        "            model=self.model,\n",
                        "            args=training_args,\n",
                        "            train_dataset=tokenized_dataset,\n",
                        "            data_collator=data_collator,\n",
                        "            tokenizer=self.tokenizer,\n",
                        "        )\n",
                        "        \n",
                        "        # بدء التدريب مع مراقبة الوقت\n",
                        "        start_time = time.time()\n",
                        "        trainer.train()\n",
                        "        end_time = time.time()\n",
                        "        \n",
                        "        training_time = end_time - start_time\n",
                        "        print(f\"⏱️ وقت التدريب: {training_time/60:.1f} دقيقة\")\n",
                        "        \n",
                        "        # حفظ النموذج\n",
                        "        trainer.save_model('/content/final_model')\n",
                        "        self.tokenizer.save_pretrained('/content/final_model')\n",
                        "        \n",
                        "        print(\"💾 تم حفظ النموذج في /content/final_model\")\n",
                        "        return trainer\n",
                        "\n",
                        "# 🚀 تشغيل التدريب\n",
                        "trainer = ColabTrainer(CONFIG)\n",
                        "print(\"✅ تم إنشاء المدرب\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 🏃‍♂️ تشغيل التدريب الكامل\n",
                        "print(\"🔥 بدء التدريب الكامل...\")\n",
                        "\n",
                        "# 1. تحضير النموذج\n",
                        "trainer.prepare_model_and_tokenizer()\n",
                        "\n",
                        "# 2. تحميل البيانات\n",
                        "dataset = trainer.load_data()\n",
                        "\n",
                        "# 3. ترميز البيانات\n",
                        "tokenized_dataset = trainer.tokenize_dataset(dataset)\n",
                        "\n",
                        "# 4. بدء التدريب\n",
                        "trained_model = trainer.train_model(tokenized_dataset)\n",
                        "\n",
                        "print(\"🎉 انتهى التدريب بنجاح!\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 📥 تحميل النموذج المدرب\n",
                        "import zipfile\n",
                        "from google.colab import files\n",
                        "\n",
                        "print(\"📦 ضغط النموذج المدرب...\")\n",
                        "\n",
                        "# ضغط النموذج\n",
                        "with zipfile.ZipFile('/content/fine_tuned_model.zip', 'w') as zipf:\n",
                        "    for root, dirs, files_list in os.walk('/content/final_model'):\n",
                        "        for file in files_list:\n",
                        "            file_path = os.path.join(root, file)\n",
                        "            arcname = os.path.relpath(file_path, '/content/final_model')\n",
                        "            zipf.write(file_path, arcname)\n",
                        "\n",
                        "print(\"📤 تحميل النموذج...\")\n",
                        "files.download('/content/fine_tuned_model.zip')\n",
                        "\n",
                        "print(\"✅ تم تحميل النموذج بنجاح!\")"
                    ]
                },
                {
                    "cell_type": "code",
                    "execution_count": None,
                    "metadata": {},
                    "source": [
                        "# 🧪 اختبار النموذج المدرب\n",
                        "print(\"🧪 اختبار النموذج المدرب...\")\n",
                        "\n",
                        "# تحميل النموذج للاختبار\n",
                        "from transformers import pipeline\n",
                        "\n",
                        "generator = pipeline(\n",
                        "    'text-generation',\n",
                        "    model='/content/final_model',\n",
                        "    tokenizer='/content/final_model',\n",
                        "    device=0 if torch.cuda.is_available() else -1\n",
                        ")\n",
                        "\n",
                        "# اختبارات سريعة\n",
                        "test_prompts = [\n",
                        "    \"مرحباً، كيف يمكنني\",\n",
                        "    \"const myFunction = () => {\",\n",
                        "    \"import React from\"\n",
                        "]\n",
                        "\n",
                        "for prompt in test_prompts:\n",
                        "    print(f\"\\n🔤 المدخل: {prompt}\")\n",
                        "    result = generator(prompt, max_length=100, num_return_sequences=1)\n",
                        "    print(f\"🤖 المخرج: {result[0]['generated_text']}\")\n",
                        "    print(\"-\" * 50)"
                    ]
                }
            ],
            "metadata": {
                "colab": {
                    "provenance": [],
                    "gpuType": "T4"
                },
                "kernelspec": {
                    "display_name": "Python 3",
                    "name": "python3"
                },
                "language_info": {
                    "name": "python"
                },
                "accelerator": "GPU"
            },
            "nbformat": 4,
            "nbformat_minor": 0
        }
        
        # حفظ الـ notebook
        notebook_path = self.cloud_folder / "Fine_Tuning_AI_Colab.ipynb"
        with open(notebook_path, 'w', encoding='utf-8') as f:
            json.dump(notebook_content, f, ensure_ascii=False, indent=2)
        
        print(f"✅ تم إنشاء Colab Notebook: {notebook_path}")
        return str(notebook_path)
    
    def create_kaggle_script(self, config: dict = None):
        """إنشاء سكريبت Kaggle للتدريب"""
        print("🏆 إنشاء Kaggle Script...")
        
        script_content = '''
# 🏆 Fine-Tuning AI - Kaggle GPU Training
# نظام تدريب متقدم باستخدام Kaggle GPUs المجانية

import os
import json
import torch
import pandas as pd
from pathlib import Path
from transformers import *
from datasets import Dataset
import kaggle

print("🚀 مرحباً بك في نظام التدريب المتقدم!")
print(f"💻 GPU متاح: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"🎮 GPU: {torch.cuda.get_device_name(0)}")
    print(f"💾 ذاكرة GPU: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")

# تحميل البيانات من Kaggle Dataset
# (رفع البيانات كـ Kaggle Dataset أولاً)
print("📊 تحميل البيانات...")

# باقي كود التدريب...
# (نفس منطق Colab مع تعديلات Kaggle)
'''
        
        script_path = self.cloud_folder / "kaggle_training.py"
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
        
        print(f"✅ تم إنشاء Kaggle Script: {script_path}")
        return str(script_path)
    
    def prepare_data_for_upload(self):
        """تحضير البيانات للرفع السحابي"""
        print("📦 تحضير البيانات للرفع...")
        
        # ضغط البيانات
        data_zip = self.cloud_folder / "training_data.zip"
        
        import zipfile
        with zipfile.ZipFile(data_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
            data_path = self.project_root / "assets" / "data"
            for file_path in data_path.rglob("*"):
                if file_path.is_file() and file_path.suffix in ['.json', '.parquet']:
                    arcname = file_path.relative_to(data_path)
                    zipf.write(file_path, arcname)
        
        file_size = data_zip.stat().st_size / (1024 * 1024)  # MB
        print(f"✅ تم ضغط البيانات: {data_zip}")
        print(f"📊 حجم الملف: {file_size:.1f} MB")
        return str(data_zip)
    
    def create_setup_guide(self):
        """إنشاء دليل الإعداد"""
        guide_content = """
# 🌐 دليل التدريب السحابي المتقدم

## 🚀 الخيارات المتاحة:

### 1. Google Colab (مجاني - موصى به!)
- **GPU مجاني:** Tesla T4 (16GB)
- **الحد الأقصى:** 12 ساعة متصلة
- **المزايا:** سهل الاستخدام، لا يحتاج إعداد

**الخطوات:**
1. افتح الرابط: https://colab.research.google.com
2. رفع الـ notebook المُعد: `Fine_Tuning_AI_Colab.ipynb`
3. تفعيل GPU: Runtime > Change runtime type > GPU
4. رفع ملف البيانات: `training_data.zip`
5. تشغيل الخلايا بالترتيب

### 2. Kaggle (مجاني)
- **GPU مجاني:** P100 أو T4
- **الحد الأقصى:** 30 ساعة أسبوعياً
- **المزايا:** قوي، مناسب للمشاريع الكبيرة

### 3. Google Cloud Platform
- **GPU متقدم:** V100, A100
- **التكلفة:** ~$1-3/ساعة
- **المزايا:** مرونة كاملة، أداء عالي

### 4. Hugging Face Spaces
- **GPU مجاني محدود**
- **المزايا:** سهل النشر والمشاركة

## 💡 نصائح للحصول على أفضل النتائج:

1. **استخدم Colab Pro للمشاريع الكبيرة** ($10/شهر)
2. **قسم البيانات على دفعات** لتجنب انقطاع الاتصال
3. **احفظ النموذج كل فترة** لتجنب فقدان التقدم
4. **استخدم fp16** لتوفير الذاكرة
5. **راقب استخدام GPU** لتحسين الأداء

## 🔧 إعدادات محسنة للتدريب السحابي:

```python
# إعدادات Colab المحسنة
CONFIG = {
    "model_name": "microsoft/DialoGPT-medium",
    "epochs": 2,  # أقل للتدريب السريع
    "batch_size": 8,  # أكبر للـ GPU
    "learning_rate": 3e-5,  # محسن للنماذج الصغيرة
    "max_length": 256,  # أقل لتوفير الذاكرة
    "fp16": True,  # مهم للـ GPU
    "gradient_accumulation_steps": 4
}
```
"""
        
        guide_path = self.cloud_folder / "CLOUD_TRAINING_GUIDE.md"
        with open(guide_path, 'w', encoding='utf-8') as f:
            f.write(guide_content)
        
        print(f"✅ تم إنشاء دليل الإعداد: {guide_path}")
        return str(guide_path)

def main():
    """الدالة الرئيسية"""
    print("🌐 إعداد التدريب السحابي المتقدم")
    print("=" * 50)
    
    # إنشاء نظام الإعداد
    cloud_setup = CloudTrainingSetup(".")
    
    # إنشاء جميع الملفات
    print("\n1. إنشاء Google Colab Notebook...")
    colab_notebook = cloud_setup.create_colab_notebook()
    
    print("\n2. إنشاء Kaggle Script...")
    kaggle_script = cloud_setup.create_kaggle_script()
    
    print("\n3. تحضير البيانات...")
    data_zip = cloud_setup.prepare_data_for_upload()
    
    print("\n4. إنشاء دليل الإعداد...")
    guide = cloud_setup.create_setup_guide()
    
    print("\n" + "=" * 50)
    print("🎉 تم إعداد التدريب السحابي بنجاح!")
    print("\n📁 الملفات المُنشأة:")
    print(f"  📚 Colab Notebook: {colab_notebook}")
    print(f"  🏆 Kaggle Script: {kaggle_script}")
    print(f"  📦 البيانات المضغوطة: {data_zip}")
    print(f"  📖 دليل الإعداد: {guide}")
    
    print("\n🚀 الخطوات التالية:")
    print("1. افتح Google Colab: https://colab.research.google.com")
    print("2. رفع الـ notebook وملف البيانات")
    print("3. تفعيل GPU وتشغيل التدريب")
    print("4. تحميل النموذج المدرب")

if __name__ == "__main__":
    main()
