#!/bin/bash

# إنشاء الملف والعنوان الرئيسي
echo "# 📊 Project Analysis Report" > analyze.md
echo "Generated on: $(date)" >> analyze.md
echo "" >> analyze.md

# إضافة شجرة المجلد
echo "## 🌳 Project Structure" >> analyze.md
echo "\`\`\`" >> analyze.md
if command -v tree > /dev/null; then
    tree lib -L 3 -I '__pycache__|*.pyc|node_modules' >> analyze.md 2>/dev/null || echo "Tree command failed, using ls instead..." >> analyze.md
else
    echo "lib/" >> analyze.md
    find lib -type d -maxdepth 3 | sort | sed 's/[^/]*\//  /g' >> analyze.md 2>/dev/null || echo "Directory listing failed" >> analyze.md
fi
echo "\`\`\`" >> analyze.md
echo "" >> analyze.md

# بدء قسم Flutter Analyze
echo -e "\n## Flutter Analyze Issues" >> analyze.md

# معالجة المخرجات وإضافة فواصل - نفس طريقة analyez.sh
flutter analyze | while IFS= read -r line; do
  if [[ -n "$line" ]]; then
    echo -e "\n/----------------------------------------------\\" >> analyze.md
    echo "$line" >> analyze.md
  fi
done

echo -e "\n/----------------------------------------------\\" >> analyze.md

echo "" >> analyze.md

# إضافة إحصائيات
echo "## 📈 Project Statistics" >> analyze.md
echo "" >> analyze.md

# إحصائيات أساسية
dart_files=$(find lib -name "*.dart" | wc -l)
total_lines=$(find lib -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "N/A")
directories=$(find lib -type d | wc -l)

echo "### 📁 File Structure" >> analyze.md
echo "- **Dart files**: \`$dart_files\`" >> analyze.md
echo "- **Total lines of code**: \`$total_lines\`" >> analyze.md
echo "- **Directories**: \`$directories\`" >> analyze.md
echo "" >> analyze.md

# إحصائيات متقدمة
echo "### 🎯 Code Metrics" >> analyze.md

# حساب متوسط أسطر لكل ملف
if [ "$dart_files" -gt 0 ] && [ "$total_lines" != "N/A" ]; then
    avg_lines=$((total_lines / dart_files))
    echo "- **Average lines per file**: \`$avg_lines\`" >> analyze.md
fi

# عدد الصفحات والخدمات والويدجت
pages_count=$(find lib/presentation/pages -name "*.dart" 2>/dev/null | wc -l)
services_count=$(find lib/core/services -name "*.dart" 2>/dev/null | wc -l)
widgets_count=$(find lib/presentation/widgets -name "*.dart" 2>/dev/null | wc -l)
providers_count=$(find lib/presentation/providers -name "*.dart" 2>/dev/null | wc -l)

echo "- **Pages**: \`$pages_count\`" >> analyze.md
echo "- **Services**: \`$services_count\`" >> analyze.md
echo "- **Custom Widgets**: \`$widgets_count\`" >> analyze.md
echo "- **Providers**: \`$providers_count\`" >> analyze.md
echo "" >> analyze.md

# إحصائيات الأداء
echo "### ⚡ Performance Components" >> analyze.md
perf_files=$(find lib/core/performance -name "*.dart" 2>/dev/null | wc -l)
echo "- **Performance optimization files**: \`$perf_files\`" >> analyze.md
echo "" >> analyze.md

# تنظيف الملفات المؤقتة
rm -f temp_analyze.txt

echo "Analysis complete! Check analyze.md file."