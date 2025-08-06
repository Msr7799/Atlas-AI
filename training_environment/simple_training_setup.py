#!/usr/bin/env python3
"""
🔥 نظام التدريب المبسط والمحسن
نظام مبسط لإعداد وتدريب نماذج الذكاء الاصطناعي
"""

import json
import subprocess
import sys
import os
from pathlib import Path
import logging

# إعداد التسجيل
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def check_and_install_requirements():
    """فحص وتثبيت المتطلبات الأساسية"""
    logger.info("🔍 فحص المتطلبات...")
    
    required_packages = [
        'torch',
        'transformers', 
        'datasets',
        'numpy',
        'pandas',
        'tqdm'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            logger.info(f"✅ {package} متوفر")
        except ImportError:
            missing_packages.append(package)
            logger.warning(f"❌ {package} غير متوفر")
    
    if missing_packages:
        logger.info(f"📦 تثبيت المكتبات المفقودة: {', '.join(missing_packages)}")
        
        try:
            # تثبيت PyTorch CPU version
            if 'torch' in missing_packages:
                subprocess.check_call([
                    sys.executable, '-m', 'pip', 'install', 
                    'torch', 'torchvision', 'torchaudio', '--index-url', 
                    'https://download.pytorch.org/whl/cpu'
                ])
                missing_packages.remove('torch')
            
            # تثبيت باقي المكتبات
            if missing_packages:
                subprocess.check_call([
                    sys.executable, '-m', 'pip', 'install'
                ] + missing_packages)
                
            logger.info("✅ تم تثبيت جميع المكتبات بنجاح")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ فشل في تثبيت المكتبات: {e}")
            return False
    
    logger.info("✅ جميع المتطلبات متوفرة")
    return True

def analyze_training_data(data_path):
    """تحليل بيانات التدريب"""
    logger.info("📊 تحليل بيانات التدريب...")
    
    data_path = Path(data_path)
    
    if not data_path.exists():
        logger.error(f"❌ مجلد البيانات غير موجود: {data_path}")
        return None
    
    json_files = list(data_path.glob('*.json'))
    
    if not json_files:
        logger.error("❌ لا توجد ملفات JSON في مجلد البيانات")
        return None
    
    total_examples = 0
    total_size = 0
    
    for file_path in json_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if isinstance(data, list):
                total_examples += len(data)
            else:
                total_examples += 1
                
            total_size += file_path.stat().st_size
            
        except Exception as e:
            logger.warning(f"⚠️ خطأ في قراءة {file_path}: {e}")
    
    logger.info(f"📁 عدد الملفات: {len(json_files)}")
    logger.info(f"📋 عدد الأمثلة: {total_examples:,}")
    logger.info(f"💾 الحجم الإجمالي: {total_size / (1024*1024):.1f} MB")
    
    return {
        'files_count': len(json_files),
        'examples_count': total_examples,
        'total_size_mb': total_size / (1024*1024)
    }

def create_simple_training_script(data_path, config):
    """إنشاء سكريپت تدريب مبسط"""
    logger.info("📝 إنشاء سكريپت التدريب...")
    
    script_content = f'''#!/usr/bin/env python3
"""
🔥 سكريپت التدريب المبسط
"""

import json
import torch
from pathlib import Path
from transformers import (
    AutoTokenizer, AutoModelForCausalLM,
    TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from datasets import Dataset
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_data():
    """تحميل البيانات"""
    logger.info("📊 تحميل البيانات...")
    
    data_path = Path("{data_path}")
    all_texts = []
    
    for json_file in data_path.glob('*.json'):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if isinstance(data, list):
                for item in data:
                    if isinstance(item, dict):
                        # دمج prompt و response
                        if 'prompt' in item and 'response' in item:
                            text = f"المستخدم: {{item['prompt']}}\\nالمساعد: {{item['response']}}"
                        elif 'text' in item:
                            text = item['text']
                        else:
                            text = str(item)
                    else:
                        text = str(item)
                    all_texts.append(text)
            else:
                all_texts.append(str(data))
                
        except Exception as e:
            logger.warning(f"خطأ في قراءة {{json_file}}: {{e}}")
    
    logger.info(f"✅ تم تحميل {{len(all_texts)}} نص")
    return all_texts

def main():
    """الدالة الرئيسية"""
    logger.info("🚀 بدء التدريب...")
    
    try:
        # تحميل البيانات
        texts = load_data()
        
        if not texts:
            logger.error("❌ لا توجد بيانات للتدريب")
            return
        
        # إعداد النموذج والمُرمز
        model_name = "{config.get('model_name', 'microsoft/DialoGPT-small')}"
        logger.info(f"🤖 تحميل النموذج: {{model_name}}")
        
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLM.from_pretrained(model_name)
        
        # إضافة pad_token إذا لم يكن موجوداً
        if tokenizer.pad_token is None:
            tokenizer.pad_token = tokenizer.eos_token
        
        # إعداد البيانات
        dataset = Dataset.from_dict({{'text': texts}})
        
        def tokenize_function(examples):
            return tokenizer(
                examples['text'],
                truncation=True,
                padding=True,
                max_length={config.get('max_length', 256)},
                return_tensors='pt'
            )
        
        tokenized_dataset = dataset.map(tokenize_function, batched=True)
        
        # إعداد التدريب
        training_args = TrainingArguments(
            output_dir='./results',
            num_train_epochs={config.get('epochs', 1)},
            per_device_train_batch_size={config.get('batch_size', 2)},
            warmup_steps={config.get('warmup_steps', 50)},
            learning_rate={config.get('learning_rate', 3e-5)},
            logging_steps={config.get('logging_steps', 10)},
            save_steps={config.get('save_steps', 100)},
            save_total_limit=1,
            remove_unused_columns=False,
        )
        
        # إعداد Data Collator
        data_collator = DataCollatorForLanguageModeling(
            tokenizer=tokenizer,
            mlm=False
        )
        
        # إنشاء Trainer
        trainer = Trainer(
            model=model,
            args=training_args,
            train_dataset=tokenized_dataset,
            data_collator=data_collator,
            tokenizer=tokenizer,
        )
        
        # بدء التدريب
        logger.info("🔥 بدء التدريب...")
        trainer.train()
        
        # حفظ النموذج
        trainer.save_model('./fine_tuned_model')
        tokenizer.save_pretrained('./fine_tuned_model')
        
        logger.info("🎉 تم التدريب بنجاح!")
        logger.info("💾 تم حفظ النموذج في: ./fine_tuned_model")
        
    except Exception as e:
        logger.error(f"❌ خطأ في التدريب: {{e}}")
        return False
    
    return True

if __name__ == "__main__":
    main()
'''
    
    script_path = Path('simple_training.py')
    with open(script_path, 'w', encoding='utf-8') as f:
        f.write(script_content)
    
    os.chmod(script_path, 0o755)
    
    logger.info(f"✅ تم إنشاء سكريپت التدريب: {script_path}")
    return str(script_path)

def main():
    """الدالة الرئيسية"""
    print("🔥 نظام التدريب المبسط والمحسن")
    print("="*50)
    
    # مسار البيانات
    data_path = Path("assets/data/specialized_datasets")
    
    # 1. فحص وتثبيت المتطلبات
    if not check_and_install_requirements():
        print("❌ فشل في إعداد المتطلبات")
        return
    
    # 2. تحليل البيانات
    data_analysis = analyze_training_data(data_path)
    if not data_analysis:
        print("❌ فشل في تحليل البيانات")
        return
    
    # 3. قراءة الإعدادات
    config_path = Path("training_config.json")
    if config_path.exists():
        with open(config_path, 'r') as f:
            config = json.load(f)
    else:
        config = {
            'model_name': 'microsoft/DialoGPT-small',
            'epochs': 1,
            'batch_size': 2,
            'learning_rate': 3e-5,
            'max_length': 256,
            'warmup_steps': 50,
            'logging_steps': 10,
            'save_steps': 100
        }
    
    # 4. إنشاء سكريپت التدريب
    script_path = create_simple_training_script(data_path, config)
    
    # 5. عرض النتائج
    print("\\n✅ النظام جاهز للتدريب!")
    print(f"📝 سكريپت التدريب: {script_path}")
    print(f"📊 عدد الأمثلة: {data_analysis['examples_count']:,}")
    print(f"💾 حجم البيانات: {data_analysis['total_size_mb']:.1f} MB")
    print("\\n🚀 لبدء التدريب، شغل الأمر:")
    print(f"python3 {script_path}")

if __name__ == "__main__":
    main()
