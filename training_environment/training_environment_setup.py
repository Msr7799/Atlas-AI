#!/usr/bin/env python3
"""
🔥 نظام إعداد بيئة التدريب المتقدم
نظام شامل لإعداد وتدريب نماذج الذكاء الاصطناعي باستخدام Fine-Tuning
"""

import os
import sys
import json
import argparse
import logging
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional
import time

# إعداد نظام التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('training_setup.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

class TrainingEnvironmentSetup:
    """نظام إعداد بيئة التدريب المتكامل"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.assets_path = self.project_root / "assets" / "data" / "specialized_datasets"
        self.training_dir = self.project_root / "training_environment"
        self.python_env = self.training_dir / "venv"
        
        # إنشاء المجلدات المطلوبة
        self.training_dir.mkdir(exist_ok=True)
        
    def check_system_requirements(self) -> Dict[str, bool]:
        """فحص متطلبات النظام"""
        logger.info("🔍 فحص متطلبات النظام...")
        
        requirements = {
            'python': self._check_python(),
            'pip': self._check_pip(),
            'git': self._check_git(),
            'cuda': self._check_cuda(),
            'data_exists': self._check_data_exists(),
            'disk_space': self._check_disk_space(),
        }
        
        # طباعة تقرير النتائج
        logger.info("📋 نتائج فحص النظام:")
        for req, status in requirements.items():
            status_icon = "✅" if status else "❌"
            logger.info(f"  {status_icon} {req}: {'متوفر' if status else 'غير متوفر'}")
            
        return requirements
    
    def _check_python(self) -> bool:
        """فحص وجود Python 3.8+"""
        try:
            result = subprocess.run(['python3', '--version'], capture_output=True, text=True)
            if result.returncode == 0:
                version = result.stdout.strip().split()[1]
                major, minor = map(int, version.split('.')[:2])
                return major >= 3 and minor >= 8
        except Exception as e:
            print(f"Error checking Python version: {e}")
        return False
    
    def _check_pip(self) -> bool:
        """فحص وجود pip"""
        try:
            subprocess.run(['pip3', '--version'], capture_output=True, check=True)
            return True
        except:
            return False
    
    def _check_git(self) -> bool:
        """فحص وجود Git"""
        try:
            subprocess.run(['git', '--version'], capture_output=True, check=True)
            return True
        except:
            return False
    
    def _check_cuda(self) -> bool:
        """فحص وجود CUDA"""
        try:
            subprocess.run(['nvidia-smi'], capture_output=True, check=True)
            return True
        except:
            return False
    
    def _check_data_exists(self) -> bool:
        """فحص وجود بيانات التدريب"""
        return self.assets_path.exists() and len(list(self.assets_path.glob('*.json'))) > 0
    
    def _check_disk_space(self) -> bool:
        """فحص المساحة المتاحة (5GB على الأقل)"""
        try:
            statvfs = os.statvfs(self.project_root)
            free_space = statvfs.f_frsize * statvfs.f_bavail
            return free_space > 5 * 1024 * 1024 * 1024  # 5GB
        except:
            return False
    
    def setup_python_environment(self) -> bool:
        """إعداد بيئة Python الافتراضية"""
        logger.info("🐍 إعداد بيئة Python...")
        
        try:
            # إنشاء بيئة افتراضية
            if not self.python_env.exists():
                logger.info("📦 إنشاء بيئة افتراضية...")
                subprocess.run([
                    'python3', '-m', 'venv', str(self.python_env)
                ], check=True)
            
            # تفعيل البيئة وتحديث pip
            pip_cmd = str(self.python_env / 'bin' / 'pip')
            
            logger.info("⬆️ تحديث pip...")
            subprocess.run([
                pip_cmd, 'install', '--upgrade', 'pip'
            ], check=True)
            
            # تثبيت المكتبات الأساسية
            logger.info("📚 تثبيت مكتبات التدريب...")
            required_packages = [
                'torch>=2.0.0',
                'transformers>=4.21.0',
                'datasets>=2.0.0',
                'tokenizers>=0.13.0',
                'accelerate>=0.20.0',
                'scikit-learn>=1.0.0',
                'pandas>=1.3.0',
                'numpy>=1.21.0',
                'tqdm>=4.64.0',
                'matplotlib>=3.5.0',
                'seaborn>=0.11.0',
                'tensorboard>=2.9.0',
                'psutil>=5.9.0',
            ]
            
            for package in required_packages:
                logger.info(f"📦 تثبيت {package}...")
                subprocess.run([
                    pip_cmd, 'install', package
                ], check=True)
            
            logger.info("✅ تم إعداد بيئة Python بنجاح")
            return True
            
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ خطأ في إعداد بيئة Python: {e}")
            return False
    
    def analyze_training_data(self) -> Dict[str, Any]:
        """تحليل بيانات التدريب"""
        logger.info("📊 تحليل بيانات التدريب...")
        
        analysis = {
            'total_files': 0,
            'total_examples': 0,
            'total_size_mb': 0,
            'file_types': {},
            'sample_data': [],
            'estimated_training_time': 0,
        }
        
        try:
            json_files = list(self.assets_path.glob('*.json'))
            analysis['total_files'] = len(json_files)
            
            total_size = 0
            total_examples = 0
            
            for file_path in json_files[:10]:  # عينة من أول 10 ملفات
                try:
                    file_size = file_path.stat().st_size
                    total_size += file_size
                    
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        
                    if isinstance(data, list):
                        total_examples += len(data)
                        if len(analysis['sample_data']) < 3:
                            analysis['sample_data'].extend(data[:2])
                    elif isinstance(data, dict):
                        total_examples += 1
                        if len(analysis['sample_data']) < 3:
                            analysis['sample_data'].append(data)
                            
                except Exception as e:
                    logger.warning(f"⚠️ خطأ في قراءة {file_path}: {e}")
            
            # تقدير الحجم الإجمالي
            if json_files:
                avg_file_size = total_size / min(len(json_files), 10)
                estimated_total_size = avg_file_size * len(json_files)
                analysis['total_size_mb'] = estimated_total_size / (1024 * 1024)
                
                # تقدير عدد الأمثلة الإجمالي
                avg_examples_per_file = total_examples / min(len(json_files), 10)
                analysis['total_examples'] = int(avg_examples_per_file * len(json_files))
                
                # تقدير وقت التدريب (دقائق)
                analysis['estimated_training_time'] = max(30, analysis['total_examples'] / 1000 * 5)
            
            logger.info(f"📈 تحليل البيانات:")
            logger.info(f"  📁 عدد الملفات: {analysis['total_files']}")
            logger.info(f"  📋 عدد الأمثلة: {analysis['total_examples']:,}")
            logger.info(f"  💾 الحجم المقدر: {analysis['total_size_mb']:.1f} MB")
            logger.info(f"  ⏱️ الوقت المقدر: {analysis['estimated_training_time']:.0f} دقيقة")
            
            return analysis
            
        except Exception as e:
            logger.error(f"❌ خطأ في تحليل البيانات: {e}")
            return analysis
    
    def create_training_script(self, config: Dict[str, Any]) -> str:
        """إنشاء سكريبت التدريب المخصص"""
        logger.info("📝 إنشاء سكريپت التدريب...")
        
        script_content = f'''#!/usr/bin/env python3
"""
🔥 سكريپت التدريب المتقدم للذكاء الاصطناعي
تم إنشاؤه تلقائياً بواسطة نظام Fine-Tuning AI
"""

import json
import torch
import pandas as pd
from pathlib import Path
from transformers import (
    AutoTokenizer, AutoModelForCausalLM,
    TrainingArguments, Trainer,
    DataCollatorForLanguageModeling
)
from datasets import Dataset
import logging
import sys
from typing import Dict, List
import time

# إعداد التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('training_progress.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

class AdvancedFineTuner:
    """نظام التدريب المتقدم"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.model_name = config.get('model_name', 'microsoft/DialoGPT-medium')
        self.max_length = config.get('max_length', 512)
        self.device = 'cuda' if torch.cuda.is_available() and config.get('use_cuda', True) else 'cpu'
        
        logger.info(f"🚀 تهيئة نظام التدريب...")
        logger.info(f"  🤖 النموذج: {{self.model_name}}")
        logger.info(f"  💻 الجهاز: {{self.device}}")
        logger.info(f"  📏 الطول الأقصى: {{self.max_length}}")
    
    def load_and_prepare_data(self, data_path: str) -> Dataset:
        """تحميل وتحضير البيانات"""
        logger.info("📊 تحميل بيانات التدريب...")
        
        data_path = Path(data_path)
        all_texts = []
        
        # قراءة جميع ملفات JSON
        json_files = list(data_path.glob('*.json'))
        logger.info(f"📁 عثر على {{len(json_files)}} ملف JSON")
        
        for file_path in json_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                if isinstance(data, list):
                    for item in data:
                        text = self._extract_text(item)
                        if text:
                            all_texts.append(text)
                elif isinstance(data, dict):
                    text = self._extract_text(data)
                    if text:
                        all_texts.append(text)
                        
            except Exception as e:
                logger.warning(f"⚠️ خطأ في قراءة {{file_path}}: {{e}}")
        
        logger.info(f"✅ تم تحميل {{len(all_texts):,}} نص للتدريب")
        
        # تحويل إلى Dataset
        dataset = Dataset.from_dict({{'text': all_texts}})
        return dataset
    
    def _extract_text(self, item: Dict) -> str:
        """استخراج النص من عنصر البيانات"""
        if isinstance(item, str):
            return item
        
        # البحث عن حقول النص الشائعة
        text_fields = ['text', 'content', 'message', 'prompt', 'response', 'question', 'answer']
        
        for field in text_fields:
            if field in item and isinstance(item[field], str):
                return item[field]
        
        # إذا لم يوجد حقل نص واضح، تحويل القاموس إلى نص
        return str(item)
    
    def prepare_tokenizer_and_model(self):
        """تحضير المُرمز والنموذج"""
        logger.info("🔧 تحضير المُرمز والنموذج...")
        
        # تحميل المُرمز
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
        
        # إضافة رمز الحشو إذا لم يكن موجوداً
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
        
        # تحميل النموذج
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            torch_dtype=torch.float16 if self.config.get('fp16', False) else torch.float32,
            device_map='auto' if self.device == 'cuda' else None
        )
        
        logger.info("✅ تم تحضير المُرمز والنموذج")
    
    def tokenize_dataset(self, dataset: Dataset) -> Dataset:
        """ترميز البيانات"""
        logger.info("🔤 ترميز البيانات...")
        
        def tokenize_function(examples):
            return self.tokenizer(
                examples['text'],
                truncation=True,
                padding=True,
                max_length=self.max_length,
                return_tensors='pt'
            )
        
        tokenized_dataset = dataset.map(
            tokenize_function,
            batched=True,
            remove_columns=dataset.column_names
        )
        
        logger.info("✅ تم ترميز البيانات")
        return tokenized_dataset
    
    def setup_training_arguments(self) -> TrainingArguments:
        """إعداد معاملات التدريب"""
        logger.info("⚙️ إعداد معاملات التدريب...")
        
        return TrainingArguments(
            output_dir='./fine_tuned_model',
            num_train_epochs=self.config.get('epochs', 3),
            per_device_train_batch_size=self.config.get('batch_size', 4),
            gradient_accumulation_steps=self.config.get('gradient_accumulation_steps', 2),
            warmup_steps=self.config.get('warmup_steps', 500),
            learning_rate=self.config.get('learning_rate', 5e-5),
            fp16=self.config.get('fp16', False),
            logging_steps=self.config.get('logging_steps', 100),
            save_steps=self.config.get('save_steps', 1000),
            save_total_limit=2,
            prediction_loss_only=True,
            remove_unused_columns=False,
            dataloader_pin_memory=False,
        )
    
    def train_model(self, tokenized_dataset: Dataset):
        """تدريب النموذج"""
        logger.info("🔥 بدء تدريب النموذج...")
        
        # إعداد معاملات التدريب
        training_args = self.setup_training_arguments()
        
        # إعداد Data Collator
        data_collator = DataCollatorForLanguageModeling(
            tokenizer=self.tokenizer,
            mlm=False
        )
        
        # إنشاء Trainer
        trainer = Trainer(
            model=self.model,
            args=training_args,
            train_dataset=tokenized_dataset,
            data_collator=data_collator,
            tokenizer=self.tokenizer,
        )
        
        # بدء التدريب
        start_time = time.time()
        trainer.train()
        end_time = time.time()
        
        training_time = end_time - start_time
        logger.info(f"✅ انتهى التدريب في {{training_time/60:.1f}} دقيقة")
        
        # حفظ النموذج النهائي
        trainer.save_model('./final_model')
        self.tokenizer.save_pretrained('./final_model')
        
        logger.info("💾 تم حفظ النموذج النهائي")
        
        return trainer

def main():
    """الدالة الرئيسية"""
    logger.info("🚀 بدء نظام التدريب المتقدم")
    
    # قراءة الإعدادات
    config = {config}
    
    # إنشاء مدرب
    trainer = AdvancedFineTuner(config)
    
    try:
        # تحضير المُرمز والنموذج
        trainer.prepare_tokenizer_and_model()
        
        # تحميل البيانات
        dataset = trainer.load_and_prepare_data("{str(self.assets_path)}")
        
        # ترميز البيانات
        tokenized_dataset = trainer.tokenize_dataset(dataset)
        
        # تدريب النموذج
        trained_model = trainer.train_model(tokenized_dataset)
        
        logger.info("🎉 تم التدريب بنجاح!")
        
    except Exception as e:
        logger.error(f"❌ خطأ في التدريب: {{e}}")
        sys.exit(1)

if __name__ == "__main__":
    main()
'''
        
        # كتابة السكريپت
        script_path = self.training_dir / 'advanced_training.py'
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
        
        # جعل السكريپت قابل للتنفيذ
        os.chmod(script_path, 0o755)
        
        logger.info(f"✅ تم إنشاء سكريپت التدريب: {script_path}")
        return str(script_path)
    
    def run_full_setup(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """تشغيل الإعداد الكامل"""
        logger.info("🔥 بدء الإعداد الكامل لبيئة التدريب")
        
        results = {
            'success': False,
            'requirements_check': {},
            'environment_setup': False,
            'data_analysis': {},
            'script_created': False,
            'script_path': '',
            'ready_for_training': False,
        }
        
        try:
            # 1. فحص المتطلبات
            results['requirements_check'] = self.check_system_requirements()
            
            # 2. إعداد البيئة
            if all(results['requirements_check'].values()):
                results['environment_setup'] = self.setup_python_environment()
            else:
                logger.warning("⚠️ بعض المتطلبات غير متوفرة")
            
            # 3. تحليل البيانات
            results['data_analysis'] = self.analyze_training_data()
            
            # 4. إنشاء سكريپت التدريب
            if results['environment_setup']:
                results['script_path'] = self.create_training_script(config)
                results['script_created'] = True
            
            # 5. التحقق من الجاهزية الكاملة
            results['ready_for_training'] = (
                results['environment_setup'] and
                results['script_created'] and
                results['data_analysis']['total_examples'] > 0
            )
            
            results['success'] = True
            
            if results['ready_for_training']:
                logger.info("🎉 النظام جاهز تماماً للتدريب!")
            else:
                logger.warning("⚠️ النظام غير جاهز تماماً للتدريب")
                
        except Exception as e:
            logger.error(f"❌ خطأ في الإعداد: {e}")
            results['error'] = str(e)
        
        return results

def main():
    """الدالة الرئيسية"""
    parser = argparse.ArgumentParser(description='🔥 نظام إعداد بيئة التدريب المتقدم')
    parser.add_argument('--project-root', required=True, help='مسار المشروع الرئيسي')
    parser.add_argument('--config', help='ملف إعدادات التدريب (JSON)')
    
    args = parser.parse_args()
    
    # قراءة الإعدادات
    default_config = {
        'model_name': 'microsoft/DialoGPT-medium',
        'epochs': 3,
        'batch_size': 4,
        'learning_rate': 5e-5,
        'max_length': 512,
        'warmup_steps': 500,
        'logging_steps': 100,
        'save_steps': 1000,
        'gradient_accumulation_steps': 2,
        'fp16': False,
        'use_cuda': True,
    }
    
    if args.config and Path(args.config).exists():
        with open(args.config, 'r') as f:
            user_config = json.load(f)
        default_config.update(user_config)
    
    # إنشاء نظام الإعداد
    setup_system = TrainingEnvironmentSetup(args.project_root)
    
    # تشغيل الإعداد الكامل
    results = setup_system.run_full_setup(default_config)
    
    # طباعة النتائج
    print("\\n" + "="*60)
    print("🔥 نتائج إعداد بيئة التدريب")
    print("="*60)
    
    if results['success']:
        print("✅ تم الإعداد بنجاح")
        if results['ready_for_training']:
            print("🚀 النظام جاهز لبدء التدريب!")
            print(f"📝 سكريپت التدريب: {results['script_path']}")
            print(f"📊 عدد الأمثلة: {results['data_analysis']['total_examples']:,}")
            print(f"⏱️ الوقت المقدر: {results['data_analysis']['estimated_training_time']:.0f} دقيقة")
        else:
            print("⚠️ بعض المتطلبات غير مكتملة")
    else:
        print("❌ فشل في الإعداد")
        if 'error' in results:
            print(f"الخطأ: {results['error']}")

if __name__ == "__main__":
    main()
