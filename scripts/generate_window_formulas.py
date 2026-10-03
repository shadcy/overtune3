import os
import subprocess
import shutil

PDFLATEX = r"C:\Users\Asus\miktex\miktex\bin\x64\pdflatex.exe"
PDFTOPPM = r"C:\Users\Asus\miktex\miktex\bin\x64\pdftoppm.exe"

FORMULAS = [
    (
        "rectangular",
        r"w[n] = 1, \quad 0 \le n \le M"
    ),
    (
        "bartlett",
        r"w[n] = 1 - \left| \frac{n - \frac{M}{2}}{\frac{M}{2}} \right|, \quad 0 \le n \le M"
    ),
    (
        "hann",
        r"w[n] = 0.5 - 0.5 \cos\left( \frac{2\pi n}{M} \right) = \sin^2\left(\frac{\pi n}{M}\right)"
    ),
    (
        "hamming",
        r"w[n] = 0.54 - 0.46 \cos\left( \frac{2\pi n}{M} \right)"
    ),
    (
        "blackman",
        r"w[n] = 0.42 - 0.5 \cos\left( \frac{2\pi n}{M} \right) + 0.08 \cos\left( \frac{4\pi n}{M} \right)"
    ),
    (
        "blackman_harris",
        r"w[n] = 0.35875 - 0.48829 \cos\left(\frac{2\pi n}{M}\right) + 0.14128 \cos\left(\frac{4\pi n}{M}\right) - 0.01168 \cos\left(\frac{6\pi n}{M}\right)"
    ),
    (
        "nuttall",
        r"w[n] = 0.355768 - 0.487396 \cos\left(\frac{2\pi n}{M}\right) + 0.144232 \cos\left(\frac{4\pi n}{M}\right) - 0.012604 \cos\left(\frac{6\pi n}{M}\right)"
    ),
    (
        "flat_top",
        r"w[n] = a_0 - a_1 \cos\left(\frac{2\pi n}{M}\right) + a_2 \cos\left(\frac{4\pi n}{M}\right) - a_3 \cos\left(\frac{6\pi n}{M}\right) + a_4 \cos\left(\frac{8\pi n}{M}\right)"
    ),
    (
        "kaiser",
        r"w[n] = \frac{I_0\left(\beta \sqrt{1 - \left(\frac{2n}{M} - 1\right)^2}\right)}{I_0(\beta)}"
    ),
    (
        "tukey",
        r"w[n] = \begin{cases} \frac{1}{2}\left[1 + \cos\left(\frac{\pi}{\alpha}\left(\frac{2n}{M} - \alpha\right)\right)\right], & 0 \le n < \frac{\alpha M}{2} \\ 1, & \frac{\alpha M}{2} \le n \le M\left(1 - \frac{\alpha}{2}\right) \\ \frac{1}{2}\left[1 + \cos\left(\frac{\pi}{\alpha}\left(\frac{2n}{M} - 2 + \alpha\right)\right)\right], & \text{otherwise} \end{cases}"
    ),
    (
        "gaussian",
        r"w[n] = \exp\left( -\frac{1}{2} \left[ \frac{n - \frac{M}{2}}{\sigma \frac{M}{2}} \right]^2 \right)"
    ),
    (
        "bohman",
        r"w[n] = (1 - |x|)\cos(\pi |x|) + \frac{1}{\pi}\sin(\pi |x|), \quad x = \frac{2n}{M} - 1"
    ),
    (
        "lanczos",
        r"w[n] = \operatorname{sinc}\left(\frac{2n}{M} - 1\right) = \frac{\sin\left(\pi\left(\frac{2n}{M} - 1\right)\right)}{\pi\left(\frac{2n}{M} - 1\right)}"
    )
]

TEMP_DIR = os.path.abspath("temp_tex_build")
OUTPUT_DIR = os.path.abspath("app/math")

os.makedirs(TEMP_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

THEMES = [
    ("dark", "1E1F24", "F0F2F5"),
    ("light", "FFFFFF", "18191C")
]

for name, formula in FORMULAS:
    for theme_name, bg_hex, fg_hex in THEMES:
        tex_content = rf"""\documentclass[border=4pt]{{standalone}}
\usepackage{{amsmath,amssymb}}
\usepackage{{xcolor}}
\pagecolor[HTML]{{{bg_hex}}}
\color[HTML]{{{fg_hex}}}
\begin{{document}}
$\displaystyle {formula}$
\end{{document}}
"""
        tex_path = os.path.join(TEMP_DIR, f"{name}_{theme_name}.tex")
        with open(tex_path, "w", encoding="utf-8") as f:
            f.write(tex_content)

        subprocess.run(
            [PDFLATEX, "-interaction=nonstopmode", f"{name}_{theme_name}.tex"],
            cwd=TEMP_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )

        pdf_path = os.path.join(TEMP_DIR, f"{name}_{theme_name}.pdf")
        prefix = os.path.join(TEMP_DIR, f"out_{name}_{theme_name}")
        subprocess.run(
            [PDFTOPPM, "-png", "-r", "200", pdf_path, prefix],
            cwd=TEMP_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )

        rendered_png = os.path.join(TEMP_DIR, f"out_{name}_{theme_name}-1.png")
        target_png = os.path.join(OUTPUT_DIR, f"win_{name}_{theme_name}.png")
        if os.path.exists(rendered_png):
            shutil.copyfile(rendered_png, target_png)
            print(f"Generated {os.path.basename(target_png)}")

shutil.rmtree(TEMP_DIR, ignore_errors=True)
print("Finished compiling all 13 LaTeX formulas.")
