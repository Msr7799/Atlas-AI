#!/bin/bash

# سكريبت تثبيت Arabic Agent على Linux
echo "🚀 تثبيت Arabic Agent على Linux..."

# إنشاء مجلد التثبيت
INSTALL_DIR="$HOME/.local/share/arabic_agent"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

echo "📁 إنشاء المجلدات..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# بناء التطبيق
echo "🔨 بناء التطبيق..."
flutter build linux --release

# نسخ الملفات
echo "📋 نسخ الملفات..."
cp -r build/linux/x64/release/bundle/* "$INSTALL_DIR/"

# نسخ الأيقونة
echo "🎨 تثبيت الأيقونة..."
cp assets/icons/app_icon1.png "$ICON_DIR/arabic_agent.png"

# إنشاء ملف .desktop
echo "🖥️ إنشاء اختصار التطبيق..."
cat > "$DESKTOP_DIR/arabic_agent.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=Arabic Agent
Name[ar]=وكيل الذكاء الاصطناعي العربي
Comment=AI Assistant with Arabic Language Support and Fine-tuning Capabilities
Comment[ar]=مساعد ذكي يدعم اللغة العربية والتدريب المتقدم للنماذج
Exec=$INSTALL_DIR/arabic_agent
Icon=$ICON_DIR/arabic_agent.png
Terminal=false
Type=Application
Categories=Office;Education;Development;Science;
Keywords=AI;Arabic;Assistant;Fine-tuning;Machine Learning;Chat;
Keywords[ar]=ذكاء اصطناعي;عربي;مساعد;تدريب;تعلم آلة;محادثة;
StartupNotify=true
MimeType=text/plain;application/json;
EOF

# جعل الملف قابل للتنفيذ
chmod +x "$DESKTOP_DIR/arabic_agent.desktop"
chmod +x "$INSTALL_DIR/arabic_agent"

# تحديث قاعدة بيانات التطبيقات
echo "🔄 تحديث قاعدة بيانات التطبيقات..."
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo "✅ تم تثبيت Arabic Agent بنجاح!"
echo "📍 يمكنك العثور على التطبيق في قائمة التطبيقات أو تشغيله من:"
echo "   $INSTALL_DIR/arabic_agent"
echo ""
echo "🎉 استمتع باستخدام Arabic Agent!"
