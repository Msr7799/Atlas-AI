import os
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

def dart_files_to_pdf(lib_folder, output_pdf):
    # انشاء ملف PDF
    c = canvas.Canvas(output_pdf, pagesize=A4)
    width, height = A4

    for root, _, files in os.walk(lib_folder):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)

                # عنوان الملف في بداية الصفحة
                c.setFont("Helvetica-Bold", 14)
                c.drawString(50, height - 50, f"File: {file_path}")
                c.setFont("Courier", 10)

                y = height - 80
                with open(file_path, "r", encoding="utf-8") as f:
                    for line in f:
                        # إذا الصفحة خلصت ينقل للصفحة اللي بعدها
                        if y < 50:
                            c.showPage()
                            y = height - 50
                            c.setFont("Courier", 10)

                        c.drawString(50, y, line.rstrip())
                        y -= 12

                c.showPage()  # كل ملف يبتدي في صفحة جديدة

    c.save()
    print(f"✅ PDF created: {output_pdf}")

if __name__ == "__main__":
    dart_files_to_pdf("lib", "flutter_lib_code.pdf")
