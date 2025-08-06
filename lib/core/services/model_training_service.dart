import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ModelTrainingService {
  static final ModelTrainingService _instance =
      ModelTrainingService._internal();
  factory ModelTrainingService() => _instance;
  ModelTrainingService._internal();

  // متغيرات التدريب
  String? _trainingDataPath;
  final bool _isTraining = false;
  final double _trainingProgress = 0.0;
  final List<Map<String, dynamic>> _trainingLogs = [];

  // إعداد بيئة التدريب
  Future<bool> initializeTrainingEnvironment() async {
    try {
      print('[MODEL_TRAINING] 🚀 بدء إعداد بيئة التدريب...');

      // إعداد مجلد التدريب
      final appDir = await getApplicationDocumentsDirectory();
      final trainingDir = Directory('${appDir.path}/fine_tuning_training');
      if (!await trainingDir.exists()) {
        await trainingDir.create(recursive: true);
      }
      _trainingDataPath = trainingDir.path;

      // تحميل إعدادات التدريب
      await _loadTrainingConfig();

      // إعداد الملفات المطلوبة
      await _prepareTrainingFiles();

      print('[MODEL_TRAINING] ✅ تم إعداد بيئة التدريب بنجاح');
      return true;
    } catch (e) {
      print('[MODEL_TRAINING] ❌ خطأ في إعداد بيئة التدريب: $e');
      return false;
    }
  }

  // تحميل بيانات التدريب من assets
  Future<void> _prepareTrainingFiles() async {
    try {
      print('[MODEL_TRAINING] 📊 تحضير ملفات التدريب...');

      // قائمة ملفات البيانات
      final datasetFiles = [
        'assets/data/specialized_datasets/fine_Tuning.json',
        'assets/data/specialized_datasets/finetuning_examples.parquet',
        'assets/data/specialized_datasets/css_code_dataset.parquet',
      ];

      // نسخ الملفات إلى مجلد التدريب
      for (final assetPath in datasetFiles) {
        try {
          final data = await rootBundle.load(assetPath);
          final fileName = assetPath.split('/').last;
          final targetFile = File('$_trainingDataPath/$fileName');

          await targetFile.writeAsBytes(data.buffer.asUint8List());
          print('[MODEL_TRAINING] ✅ تم نسخ: $fileName');
        } catch (e) {
          print('[MODEL_TRAINING] ⚠️ لم يتم العثور على: $assetPath');
        }
      }

      // إنشاء سكريبت التدريب Python
      await _createTrainingScript();
    } catch (e) {
      print('[MODEL_TRAINING] ❌ خطأ في تحضير الملفات: $e');
    }
  }

  // إنشاء سكريبت التدريب Python
  Future<void> _createTrainingScript() async {
    final scriptContent = '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
نظام التدريب المتقدم للنماذج اللغوية
Fine-Tuning System for Language Models
"""

import os
import json
import pandas as pd
import numpy as np
import torch
import transformers
from transformers import (
    AutoTokenizer, 
    AutoModelForCausalLM,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from datasets import Dataset, load_dataset
import wandb
from datetime import datetime
import argparse
import logging

# إعداد التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('training.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class FineTuningTrainer:
    def __init__(self, config_path="training_config.json"):
        """تهيئة نظام التدريب"""
        self.config = self.load_config(config_path)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        logger.info(f"🚀 بدء التدريب على {self.device}")
        
    def load_config(self, config_path):
        """تحميل إعدادات التدريب"""
        default_config = {
            "model_name": "microsoft/DialoGPT-medium",
            "dataset_path": "./fine_Tuning.json",
            "output_dir": "./fine_tuned_model",
            "num_train_epochs": 3,
            "per_device_train_batch_size": 4,
            "per_device_eval_batch_size": 4,
            "learning_rate": 5e-5,
            "weight_decay": 0.01,
            "logging_steps": 10,
            "save_steps": 500,
            "eval_steps": 500,
            "warmup_steps": 100,
            "max_length": 512
        }
        
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            return {**default_config, **config}
        except FileNotFoundError:
            logger.warning("⚠️ لم يتم العثور على ملف الإعدادات، استخدام الإعدادات الافتراضية")
            return default_config
    
    def prepare_dataset(self):
        """تحضير بيانات التدريب"""
        logger.info("📊 تحضير بيانات التدريب...")
        
        try:
            # تحميل البيانات من JSON
            with open(self.config["dataset_path"], 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # استخراج النصوص من خلايا الكود
            texts = []
            if 'cells' in data:
                for cell in data['cells']:
                    if cell.get('cell_type') == 'code' and cell.get('source'):
                        source = cell['source']
                        if isinstance(source, list):
                            text = ''.join(source)
                        else:
                            text = str(source)
                        
                        if len(text.strip()) > 10:  # تجاهل النصوص القصيرة جداً
                            texts.append(text.strip())
            
            logger.info(f"📈 تم استخراج {len(texts)} عينة تدريب")
            
            # إنشاء Dataset
            dataset = Dataset.from_dict({"text": texts})
            
            # تقسيم البيانات
            split_dataset = dataset.train_test_split(test_size=0.1)
            
            return split_dataset["train"], split_dataset["test"]
            
        except Exception as e:
            logger.error(f"❌ خطأ في تحضير البيانات: {e}")
            raise
    
    def tokenize_function(self, examples):
        """تحويل النصوص إلى tokens"""
        return self.tokenizer(
            examples["text"],
            truncation=True,
            padding=True,
            max_length=self.config["max_length"]
        )
    
    def train_model(self):
        """بدء عملية التدريب"""
        try:
            logger.info("🤖 تحميل النموذج والمحلل اللغوي...")
            
            # تحميل النموذج والتوكناير
            self.tokenizer = AutoTokenizer.from_pretrained(self.config["model_name"])
            
            # إضافة pad token إذا لم يكن موجوداً
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            model = AutoModelForCausalLM.from_pretrained(
                self.config["model_name"],
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
            )
            
            # تحضير البيانات
            train_dataset, eval_dataset = self.prepare_dataset()
            
            # تطبيق التوكنة
            train_dataset = train_dataset.map(self.tokenize_function, batched=True)
            eval_dataset = eval_dataset.map(self.tokenize_function, batched=True)
            
            # إعداد Data Collator
            data_collator = DataCollatorForLanguageModeling(
                tokenizer=self.tokenizer,
                mlm=False
            )
            
            # إعدادات التدريب
            training_args = TrainingArguments(
                output_dir=self.config["output_dir"],
                num_train_epochs=self.config["num_train_epochs"],
                per_device_train_batch_size=self.config["per_device_train_batch_size"],
                per_device_eval_batch_size=self.config["per_device_eval_batch_size"],
                learning_rate=self.config["learning_rate"],
                weight_decay=self.config["weight_decay"],
                logging_steps=self.config["logging_steps"],
                save_steps=self.config["save_steps"],
                eval_steps=self.config["eval_steps"],
                evaluation_strategy="steps",
                save_strategy="steps",
                warmup_steps=self.config["warmup_steps"],
                load_best_model_at_end=True,
                metric_for_best_model="eval_loss",
                greater_is_better=False,
                dataloader_pin_memory=False,
                report_to="none"  # تعطيل wandb
            )
            
            # إنشاء المدرب
            trainer = Trainer(
                model=model,
                args=training_args,
                train_dataset=train_dataset,
                eval_dataset=eval_dataset,
                data_collator=data_collator,
                tokenizer=self.tokenizer
            )
            
            # بدء التدريب
            logger.info("🔥 بدء عملية التدريب...")
            training_result = trainer.train()
            
            # حفظ النموذج
            logger.info("💾 حفظ النموذج المدرب...")
            trainer.save_model()
            self.tokenizer.save_pretrained(self.config["output_dir"])
            
            # إنشاء تقرير النتائج
            self.generate_training_report(training_result)
            
            logger.info("🎉 تم انتهاء التدريب بنجاح!")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ خطأ في التدريب: {e}")
            return False
    
    def generate_training_report(self, training_result):
        """إنشاء تقرير نتائج التدريب"""
        report = {
            "training_completed": True,
            "training_loss": training_result.training_loss,
            "global_step": training_result.global_step,
            "config": self.config,
            "timestamp": datetime.now().isoformat()
        }
        
        with open("training_report.json", 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        logger.info("📊 تم إنشاء تقرير التدريب: training_report.json")

def main():
    """الدالة الرئيسية"""
    parser = argparse.ArgumentParser(description='نظام التدريب المتقدم')
    parser.add_argument('--config', default='training_config.json', help='مسار ملف الإعدادات')
    args = parser.parse_args()
    
    try:
        trainer = FineTuningTrainer(args.config)
        success = trainer.train_model()
        
        if success:
            print("✅ تم التدريب بنجاح!")
            exit(0)
        else:
            print("❌ فشل التدريب!")
            exit(1)
            
    except Exception as e:
        logger.error(f"❌ خطأ عام: {e}")
        exit(1)

if __name__ == "__main__":
    main()
''';

    final scriptFile = File('$_trainingDataPath/fine_tuning_trainer.py');
    await scriptFile.writeAsString(scriptContent);

    // إنشاء ملف requirements.txt
    final requirementsContent = '''torch>=1.9.0
transformers>=4.20.0
datasets>=2.0.0
pandas>=1.3.0
numpy>=1.21.0
accelerate>=0.12.0
evaluate>=0.2.0
wandb>=0.12.0
scikit-learn>=1.0.0
''';

    final requirementsFile = File('$_trainingDataPath/requirements.txt');
    await requirementsFile.writeAsString(requirementsContent);

    print('[MODEL_TRAINING] ✅ تم إنشاء سكريبت التدريب');
  }

  // تحميل إعدادات التدريب
  Future<void> _loadTrainingConfig() async {
    // يتم تحميل الإعدادات عند الحاجة في سكريبت Python
    print('[MODEL_TRAINING] ✅ إعدادات التدريب جاهزة');
  }

  // حالة التدريب
  bool get isTraining => _isTraining;
  double get trainingProgress => _trainingProgress;
  List<Map<String, dynamic>> get trainingLogs =>
      List.unmodifiable(_trainingLogs);

  // إنشاء سكريبت التدريب المحسن مع المراقبة
  Future<String> createTrainingScript(Map<String, dynamic> config) async {
    final scriptContent =
        '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
نظام التدريب المتقدم مع المراقبة في الوقت الفعلي
Advanced Training System with Real-time Monitoring
"""

import os
import json
import pandas as pd
import numpy as np
import torch
import transformers
from transformers import (
    AutoTokenizer, 
    AutoModelForCausalLM,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling,
    EarlyStoppingCallback
)
from datasets import Dataset, load_dataset
import time
import sys
from datetime import datetime
import logging
from typing import Dict, List, Any

# إعداد التسجيل المتقدم
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('training_detailed.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class AdvancedFineTuningTrainer:
    def __init__(self, config_path="training_config.json"):
        """تهيئة نظام التدريب المتقدم"""
        self.config = self.load_config(config_path)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.training_start_time = None
        self.progress_file = "training_progress.json"
        
        logger.info(f"🚀 تهيئة التدريب على {self.device}")
        logger.info(f"💾 ذاكرة GPU متاحة: {torch.cuda.get_device_properties(0).total_memory // 1024**3 if torch.cuda.is_available() else 'N/A'} GB")
        
    def load_config(self, config_path: str) -> Dict[str, Any]:
        """تحميل إعدادات التدريب المحسنة"""
        default_config = {
            "model_name": "${config['model_name']}",
            "dataset_path": "./fine_Tuning.json",
            "parquet_path": "./finetuning_examples.parquet",
            "output_dir": "./fine_tuned_model",
            "num_train_epochs": ${config['epochs']},
            "per_device_train_batch_size": ${config['batch_size']},
            "per_device_eval_batch_size": ${config['batch_size']},
            "learning_rate": ${config['learning_rate']},
            "weight_decay": 0.01,
            "logging_steps": ${config['logging_steps']},
            "save_steps": ${config['save_steps']},
            "eval_steps": ${config['save_steps']},
            "warmup_steps": ${config['warmup_steps']},
            "max_length": ${config['max_length']},
            "gradient_accumulation_steps": ${config['gradient_accumulation_steps']},
            "fp16": ${config['fp16']},
            "dataloader_num_workers": 4,
            "load_best_model_at_end": True,
            "metric_for_best_model": "eval_loss",
            "greater_is_better": False,
            "save_total_limit": 3
        }
        
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            return {**default_config, **config}
        except FileNotFoundError:
            logger.warning("⚠️ استخدام الإعدادات الافتراضية")
            return default_config
    
    def prepare_massive_dataset(self) -> tuple:
        """تحضير البيانات الضخمة من multiple sources"""
        logger.info("📊 تحضير البيانات الضخمة...")
        self.update_progress(0.05, "تحميل البيانات من المصادر المتعددة")
        
        all_texts = []
        
        # 1. تحميل JSON data
        try:
            with open(self.config["dataset_path"], 'r', encoding='utf-8') as f:
                json_data = json.load(f)
            
            if 'cells' in json_data:
                for i, cell in enumerate(json_data['cells']):
                    if cell.get('cell_type') == 'code' and cell.get('source'):
                        source = cell['source']
                        if isinstance(source, list):
                            text = ''.join(source)
                        else:
                            text = str(source)
                        
                        if len(text.strip()) > 20:
                            all_texts.append(text.strip())
                    
                    # تحديث التقدم كل 1000 عنصر
                    if i % 1000 == 0:
                        progress = 0.05 + (i / len(json_data['cells'])) * 0.15
                        self.update_progress(progress, f"معالجة JSON: {i}/{len(json_data['cells'])}")
                        
            logger.info(f"✅ تم استخراج {len(all_texts)} عينة من JSON")
            
        except Exception as e:
            logger.error(f"❌ خطأ في تحميل JSON: {e}")
        
        # 2. تحميل Parquet data
        try:
            if os.path.exists(self.config["parquet_path"]):
                self.update_progress(0.20, "تحميل بيانات Parquet")
                df = pd.read_parquet(self.config["parquet_path"])
                
                # استخراج النصوص من العمود المناسب
                text_columns = ['text', 'code', 'content', 'source']
                for col in text_columns:
                    if col in df.columns:
                        parquet_texts = df[col].dropna().astype(str).tolist()
                        valid_texts = [t for t in parquet_texts if len(t.strip()) > 20]
                        all_texts.extend(valid_texts)
                        logger.info(f"✅ أضيف {len(valid_texts)} عينة من عمود {col}")
                        break
                        
        except Exception as e:
            logger.error(f"⚠️ تعذر تحميل Parquet: {e}")
        
        # 3. فلترة وتنظيف البيانات
        self.update_progress(0.35, "تنظيف وفلترة البيانات")
        
        # إزالة التكرارات
        all_texts = list(set(all_texts))
        
        # فلترة النصوص القصيرة والطويلة جداً
        filtered_texts = []
        for text in all_texts:
            text_len = len(text)
            if 50 <= text_len <= 2048:  # نصوص متوسطة الطول
                filtered_texts.append(text)
        
        logger.info(f"📈 البيانات النهائية: {len(filtered_texts)} عينة تدريب")
        logger.info(f"📊 متوسط طول النص: {np.mean([len(t) for t in filtered_texts]):.1f} حرف")
        
        # إنشاء Dataset
        dataset = Dataset.from_dict({"text": filtered_texts})
        
        # تقسيم البيانات (90% تدريب، 10% تقييم)
        split_dataset = dataset.train_test_split(test_size=0.1, seed=42)
        
        self.update_progress(0.40, f"تم تحضير {len(filtered_texts)} عينة للتدريب")
        
        return split_dataset["train"], split_dataset["test"]
    
    def tokenize_function(self, examples):
        """تحويل النصوص إلى tokens محسن"""
        return self.tokenizer(
            examples["text"],
            truncation=True,
            padding="max_length",
            max_length=self.config["max_length"],
            return_attention_mask=True
        )
    
    def update_progress(self, progress: float, step: str):
        """تحديث ملف التقدم للمراقبة"""
        progress_data = {
            "progress": progress,
            "step": step,
            "timestamp": datetime.now().isoformat(),
            "elapsed_time": time.time() - self.training_start_time if self.training_start_time else 0
        }
        
        try:
            with open(self.progress_file, 'w', encoding='utf-8') as f:
                json.dump(progress_data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"فشل في تحديث التقدم: {e}")
        
        logger.info(f"🔄 {step} - {progress*100:.1f}%")
    
    def train_model(self):
        """بدء عملية التدريب المتقدمة"""
        try:
            self.training_start_time = time.time()
            logger.info("🔥 بدء التدريب المتقدم...")
            
            # 1. تحميل النموذج والتوكناير
            self.update_progress(0.00, "تحميل النموذج والمحلل اللغوي")
            
            self.tokenizer = AutoTokenizer.from_pretrained(self.config["model_name"])
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            model = AutoModelForCausalLM.from_pretrained(
                self.config["model_name"],
                torch_dtype=torch.float16 if self.config["fp16"] else torch.float32,
                device_map="auto" if torch.cuda.is_available() else None
            )
            
            # 2. تحضير البيانات الضخمة
            train_dataset, eval_dataset = self.prepare_massive_dataset()
            
            # 3. تطبيق التوكنة
            self.update_progress(0.45, "تطبيق التوكنة على البيانات")
            
            train_dataset = train_dataset.map(
                self.tokenize_function, 
                batched=True,
                remove_columns=train_dataset.column_names,
                desc="Tokenizing train dataset"
            )
            
            eval_dataset = eval_dataset.map(
                self.tokenize_function, 
                batched=True,
                remove_columns=eval_dataset.column_names,
                desc="Tokenizing eval dataset"
            )
            
            # 4. إعداد Data Collator
            data_collator = DataCollatorForLanguageModeling(
                tokenizer=self.tokenizer,
                mlm=False
            )
            
            # 5. إعدادات التدريب المحسنة
            self.update_progress(0.50, "إعداد معاملات التدريب")
            
            training_args = TrainingArguments(
                output_dir=self.config["output_dir"],
                num_train_epochs=self.config["num_train_epochs"],
                per_device_train_batch_size=self.config["per_device_train_batch_size"],
                per_device_eval_batch_size=self.config["per_device_eval_batch_size"],
                learning_rate=self.config["learning_rate"],
                weight_decay=self.config["weight_decay"],
                logging_steps=self.config["logging_steps"],
                save_steps=self.config["save_steps"],
                eval_steps=self.config["eval_steps"],
                evaluation_strategy="steps",
                save_strategy="steps",
                warmup_steps=self.config["warmup_steps"],
                gradient_accumulation_steps=self.config["gradient_accumulation_steps"],
                fp16=self.config["fp16"],
                dataloader_num_workers=self.config["dataloader_num_workers"],
                load_best_model_at_end=self.config["load_best_model_at_end"],
                metric_for_best_model=self.config["metric_for_best_model"],
                greater_is_better=self.config["greater_is_better"],
                save_total_limit=self.config["save_total_limit"],
                report_to="none",
                logging_dir="./logs",
                run_name=f"fine_tuning_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            )
            
            # 6. إنشاء المدرب مع Early Stopping
            trainer = Trainer(
                model=model,
                args=training_args,
                train_dataset=train_dataset,
                eval_dataset=eval_dataset,
                data_collator=data_collator,
                tokenizer=self.tokenizer,
                callbacks=[EarlyStoppingCallback(early_stopping_patience=3)]
            )
            
            # 7. بدء التدريب الفعلي
            self.update_progress(0.55, "بدء التدريب الفعلي للنموذج")
            logger.info("⚡ بدء التدريب الفعلي...")
            
            training_result = trainer.train()
            
            # 8. حفظ النموذج
            self.update_progress(0.95, "حفظ النموذج المدرب")
            logger.info("💾 حفظ النموذج...")
            
            trainer.save_model()
            self.tokenizer.save_pretrained(self.config["output_dir"])
            
            # 9. إنشاء تقرير مفصل
            self.generate_detailed_report(training_result, train_dataset, eval_dataset)
            
            self.update_progress(1.0, "تم انتهاء التدريب بنجاح")
            logger.info("🎉 تم التدريب بنجاح!")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ خطأ في التدريب: {e}")
            self.update_progress(0.0, f"خطأ: {str(e)}")
            return False
    
    def generate_detailed_report(self, training_result, train_dataset, eval_dataset):
        """إنشاء تقرير مفصل للنتائج"""
        total_time = time.time() - self.training_start_time
        
        report = {
            "training_completed": True,
            "model_name": self.config["model_name"],
            "training_loss": training_result.training_loss,
            "global_step": training_result.global_step,
            "total_training_time_minutes": total_time / 60,
            "train_dataset_size": len(train_dataset),
            "eval_dataset_size": len(eval_dataset),
            "epochs_completed": self.config["num_train_epochs"],
            "config": self.config,
            "device_used": str(self.device),
            "timestamp": datetime.now().isoformat(),
            "performance_metrics": {
                "samples_per_second": len(train_dataset) / total_time,
                "total_parameters": sum(p.numel() for p in model.parameters() if p.requires_grad)
            }
        }
        
        # حفظ التقرير
        report_files = [
            "training_report.json",
            "detailed_training_report.json"
        ]
        
        for report_file in report_files:
            with open(report_file, 'w', encoding='utf-8') as f:
                json.dump(report, f, ensure_ascii=False, indent=2)
        
        logger.info("📊 تم إنشاء التقرير المفصل")

def main():
    """الدالة الرئيسية المحسنة"""
    try:
        trainer = AdvancedFineTuningTrainer()
        success = trainer.train_model()
        
        if success:
            print("✅ تم التدريب بنجاح!")
            exit(0)
        else:
            print("❌ فشل التدريب!")
            exit(1)
            
    except Exception as e:
        logger.error(f"❌ خطأ عام: {e}")
        exit(1)

if __name__ == "__main__":
    main()
''';

    final scriptFile = File(
      '$_trainingDataPath/advanced_fine_tuning_trainer.py',
    );
    await scriptFile.writeAsString(scriptContent);

    print('[MODEL_TRAINING] ✅ تم إنشاء سكريبت التدريب المتقدم');
    return scriptFile.path;
  }

  // بدء التدريب المحسن مع المراقبة المتقدمة
  Future<bool> startTrainingAdvanced({
    required String scriptPath,
    required Function(double, String) onProgress,
    required Function(String) onLog,
  }) async {
    try {
      onLog('🚀 بدء تشغيل سكريبت Python المتقدم...');

      // التحقق من متطلبات Python
      final pythonCheck = await _checkPythonRequirements();
      if (!pythonCheck) {
        onLog('❌ متطلبات Python غير مكتملة');
        return false;
      }

      // تشغيل سكريپت التدريب
      final process = await Process.start('python3', [
        'advanced_fine_tuning_trainer.py',
      ], workingDirectory: _trainingDataPath);

      // مراقبة التقدم والإخراج
      _monitorAdvancedTraining(process, onProgress, onLog);

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        onLog('🎉 تم التدريب بنجاح!');
        return true;
      } else {
        onLog('❌ فشل في التدريب - Exit Code: $exitCode');
        return false;
      }
    } catch (e) {
      onLog('❌ خطأ في تشغيل التدريب: $e');
      return false;
    }
  }

  // فحص متطلبات Python
  Future<bool> _checkPythonRequirements() async {
    try {
      // فحص Python
      final pythonResult = await Process.run('python3', ['--version']);
      if (pythonResult.exitCode != 0) {
        print('[REQUIREMENTS] ❌ Python غير متاح');
        return false;
      }

      // فحص pip
      final pipResult = await Process.run('python3', [
        '-m',
        'pip',
        '--version',
      ]);
      if (pipResult.exitCode != 0) {
        print('[REQUIREMENTS] ❌ pip غير متاح');
        return false;
      }

      // تثبيت المتطلبات
      print('[REQUIREMENTS] 📦 تثبيت المتطلبات...');
      final installResult = await Process.run('python3', [
        '-m',
        'pip',
        'install',
        '-r',
        'requirements.txt',
      ], workingDirectory: _trainingDataPath);

      if (installResult.exitCode == 0) {
        print('[REQUIREMENTS] ✅ تم تثبيت المتطلبات بنجاح');
        return true;
      } else {
        print('[REQUIREMENTS] ⚠️ تحذير في تثبيت المتطلبات');
        return true; // نكمل حتى لو فيه تحذيرات
      }
    } catch (e) {
      print('[REQUIREMENTS] ❌ خطأ في فحص المتطلبات: $e');
      return false;
    }
  }

  // مراقبة متقدمة للتدريب
  void _monitorAdvancedTraining(
    Process process,
    Function(double, String) onProgress,
    Function(String) onLog,
  ) {
    // مراقبة ملف التقدم
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkProgressFile(onProgress, timer);
    });

    // مراقبة الإخراج
    process.stdout.transform(utf8.decoder).listen((data) {
      final lines = data.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          onLog('[TRAINING] $line');
          _parseTrainingOutput(line, onProgress);
        }
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      final lines = data.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          onLog('[ERROR] $line');
        }
      }
    });
  }

  // فحص ملف التقدم
  void _checkProgressFile(Function(double, String) onProgress, Timer timer) {
    try {
      final progressFile = File('$_trainingDataPath/training_progress.json');
      if (progressFile.existsSync()) {
        final content = progressFile.readAsStringSync();
        final progress = jsonDecode(content);

        onProgress(
          progress['progress']?.toDouble() ?? 0.0,
          progress['step'] ?? 'جاري التدريب...',
        );

        // إيقاف المؤقت عند الانتهاء
        if ((progress['progress']?.toDouble() ?? 0.0) >= 1.0) {
          timer.cancel();
        }
      }
    } catch (e) {
      // تجاهل الأخطاء في قراءة ملف التقدم
    }
  }

  // تحليل إخراج التدريب
  void _parseTrainingOutput(String line, Function(double, String) onProgress) {
    // استخراج تقدم التدريب من إخراج transformers
    if (line.contains('Training:')) {
      final regex = RegExp(r'(\d+)%');
      final match = regex.firstMatch(line);
      if (match != null) {
        final percentage = double.tryParse(match.group(1)!) ?? 0.0;
        onProgress(0.5 + (percentage / 100.0) * 0.45, 'تدريب النموذج...');
      }
    }
  }

  // إيقاف التدريب المحسن
  Future<void> stopTrainingAdvanced() async {
    // قتل عمليات Python
    try {
      await Process.run('pkill', ['-f', 'advanced_fine_tuning_trainer.py']);
      print('[MODEL_TRAINING] ⏹️ تم إيقاف التدريب');
    } catch (e) {
      print('[MODEL_TRAINING] ⚠️ لم يتم العثور على عملية للإيقاف');
    }
  }

  // الحصول على معلومات البيانات
  Future<Map<String, dynamic>> getDatasetInfo() async {
    try {
      final Map<String, dynamic> info = {};

      // معلومات JSON
      final jsonFile = File('$_trainingDataPath/fine_Tuning.json');
      if (await jsonFile.exists()) {
        final content = await jsonFile.readAsString();
        final data = jsonDecode(content);

        if (data['cells'] != null) {
          final codeCells = (data['cells'] as List)
              .where((cell) => cell['cell_type'] == 'code')
              .length;

          info['json_cells'] = data['cells'].length;
          info['json_code_cells'] = codeCells;
        }
      }

      // معلومات Parquet
      final parquetFile = File(
        '$_trainingDataPath/finetuning_examples.parquet',
      );
      if (await parquetFile.exists()) {
        final size = await parquetFile.length();
        info['parquet_size_mb'] = size / (1024 * 1024);
      }

      return info;
    } catch (e) {
      print('[DATASET_INFO] ❌ خطأ: $e');
      return {};
    }
  }

  // تصدير النموذج
  Future<String?> exportModel() async {
    try {
      final modelDir = Directory('$_trainingDataPath/fine_tuned_model');
      if (!await modelDir.exists()) {
        return null;
      }

      final exportDir = Directory('$_trainingDataPath/exported_model');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // نسخ ملفات النموذج
      await for (final file in modelDir.list()) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final targetFile = File('${exportDir.path}/$fileName');
          await file.copy(targetFile.path);
        }
      }

      return exportDir.path;
    } catch (e) {
      print('[EXPORT] ❌ خطأ في التصدير: $e');
      return null;
    }
  }

  // تقييم النموذج
  Future<Map<String, dynamic>?> evaluateModel() async {
    try {
      final reportFile = File(
        '$_trainingDataPath/detailed_training_report.json',
      );
      if (await reportFile.exists()) {
        final content = await reportFile.readAsString();
        return jsonDecode(content);
      }
      return null;
    } catch (e) {
      print('[EVALUATION] ❌ خطأ في التقييم: $e');
      return null;
    }
  }

  // واجهات بسيطة للتدريب (تحويل للدوال المحسنة)
  Future<bool> startTraining({
    required String scriptPath,
    required Function(double, String) onProgress,
    required Function(String) onLog,
  }) => startTrainingAdvanced(
    scriptPath: scriptPath,
    onProgress: onProgress,
    onLog: onLog,
  );

  Future<void> stopTraining() => stopTrainingAdvanced();

  // تنظيف الموارد
  void dispose() {
    // تنظيف أي موارد مفتوحة
  }

  // تحليل النموذج المدرب
  Future<ModelAnalysis> analyzeTrainedModel(String modelPath) async {
    try {
      // قراءة ملفات النموذج
      final modelDir = Directory(modelPath);
      if (!await modelDir.exists()) {
        throw Exception('مسار النموذج غير موجود');
      }

      // تحليل الملفات
      final files = await modelDir.list().toList();
      final modelSize = await _calculateDirectorySize(modelDir);

      // قراءة إعدادات النموذج
      final configFile = File('$modelPath/config.json');
      Map<String, dynamic>? modelConfig;
      if (await configFile.exists()) {
        final configContent = await configFile.readAsString();
        modelConfig = jsonDecode(configContent);
      }

      return ModelAnalysis(
        modelPath: modelPath,
        sizeInMB: modelSize / (1024 * 1024),
        fileCount: files.length,
        config: modelConfig,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في تحليل النموذج: $e');
    }
  }

  // حساب حجم المجلد
  Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
}

// نموذج نتيجة التدريب
class TrainingResult {
  final bool success;
  final double finalLoss;
  final int epochs;
  final String modelPath;
  final List<Map<String, dynamic>> logs;
  final String? error;

  TrainingResult({
    required this.success,
    required this.finalLoss,
    required this.epochs,
    required this.modelPath,
    required this.logs,
    this.error,
  });
}

// نموذج تحليل النموذج
class ModelAnalysis {
  final String modelPath;
  final double sizeInMB;
  final int fileCount;
  final Map<String, dynamic>? config;
  final DateTime createdAt;

  ModelAnalysis({
    required this.modelPath,
    required this.sizeInMB,
    required this.fileCount,
    this.config,
    required this.createdAt,
  });
}
