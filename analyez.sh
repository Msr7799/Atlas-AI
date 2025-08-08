#!/bin/bash

# إنشاء الملف والعنوان الرئيسي
echo "# Project Analysis Report" > analyze.md

# إضافة شجرة المجلد
echo -e "\n## Project Structure" >> analyze.md
tree lib -L 3 >> analyze.md

# بدء قسم Flutter Analyze
echo -e "\n## Flutter Analyze Issues" >> analyze.md

# معالجة المخرجات وإضافة فواصل
flutter analyze | while IFS= read -r line; do
  if [[ -n "$line" ]]; then
    echo -e "\n/----------------------------------------------\\" >> analyze.md
    echo "$line" >> analyze.md
  fi
done

echo -e "\n/----------------------------------------------\\" >> analyze.md