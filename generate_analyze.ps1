# PowerShell script for Flutter project analysis

# إنشاء الملف والعنوان الرئيسي
"# 📊 Project Analysis Report" | Out-File -FilePath "analyze.md" -Encoding UTF8
"Generated on: $(Get-Date)" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

# إضافة شجرة المجلد
"## 🌳 Project Structure" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"``````" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

# استخدام tree أو Get-ChildItem
if (Get-Command tree -ErrorAction SilentlyContinue) {
    tree lib /F | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
} else {
    Get-ChildItem -Path lib -Recurse -Directory | ForEach-Object {
        $depth = ($_.FullName -replace [regex]::Escape((Get-Location).Path + "\lib"), "").Split('\').Length - 1
        "  " * $depth + $_.Name | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
    }
}

"``````" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

# بدء قسم Flutter Analyze
"" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"## Flutter Analyze Issues" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

# تشغيل flutter analyze وتنسيق النتائج
try {
    $flutterOutput = flutter analyze 2>&1
    if ($flutterOutput) {
        foreach ($line in $flutterOutput) {
            if ($line.Trim() -ne "") {
                "" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
                "/----------------------------------------------\" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
                $line | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
            }
        }
        "" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
        "/----------------------------------------------\" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
    }
} catch {
    "Error running flutter analyze: $_" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
}

# إضافة إحصائيات
"" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"## 📈 Project Statistics" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

$dartFiles = (Get-ChildItem -Path lib -Filter "*.dart" -Recurse).Count
$totalLines = (Get-ChildItem -Path lib -Filter "*.dart" -Recurse | Get-Content | Measure-Object -Line).Lines
$directories = (Get-ChildItem -Path lib -Directory -Recurse).Count

"" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"### 📁 File Structure" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"- **Dart files**: ``$dartFiles``" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"- **Total lines of code**: ``$totalLines``" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8
"- **Directories**: ``$directories``" | Out-File -FilePath "analyze.md" -Append -Encoding UTF8

Write-Host "Analysis complete! Check analyze.md file."
