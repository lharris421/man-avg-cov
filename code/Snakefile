import re
from pathlib import Path
from glob import glob
import os

configfile: "config.yaml"
MS     = config["manuscript"]
EXCL   = set(config["exclude_figs"])

# Get all R script names without extensions
files = [Path(f).stem for f in glob('code/*.R')]
exclude = {'setup'}

# Function to determine output file extensions
OUT_PATH_RE = re.compile(
    r"""
    ["']                # opening quote
    out/                # required prefix
    (?P<fname>[^{}\\/\"']+?)   # file name, no braces or slashes
    \.(?P<ext>pdf|png|tex)     # allowed extensions
    ["']                # closing quote
    """,
    re.IGNORECASE | re.VERBOSE,
)

def find_stems():
    """Yield (script‑stem, extension) pairs for every literal out/<file>.<ext>."""
    for script in Path("code").glob("*.R"):
        stem = script.stem
        if stem in EXCL:
            continue

        with script.open() as fh:
            for line in fh:
                m = OUT_PATH_RE.search(line)
                if m:                         # found a literal out/<file>.<ext>
                    yield stem, m.group("ext").lower()
                    break                     # one match per script

FIGS = dict(find_stems()) 
FIG_OUTPUTS = expand(
    "code/out/{stem}.{ext}", zip,
    stem = FIGS.keys(),
    ext  = FIGS.values()
)

## Logging
os.makedirs("logs", exist_ok=True)
with open("logs/fig_discovery.log", "w") as lf:
    lf.write("# Detected figure scripts and products\n\n")
    lf.write("FIGS mapping (stem  →  ext)\n")
    for s, e in FIGS.items():
        lf.write(f"  {s:20} -> {e}\n")
    lf.write("\nConcrete output paths\n")
    for p in FIG_OUTPUTS:
        lf.write(f"  {p}\n")
    lf.write("\n")

rule all:
    input:
        f"{MS}.pdf",          # final manuscript
        FIG_OUTPUTS           # all figures

rule fig:
    input:
        "code/{stem}.R"
    output:
        "code/out/{stem}.{ext}"
    log:
        "logs/fig_{stem}.{ext}.log"
    shell:
        r"""
        (
          cd code
          Rscript "$(basename {wildcards.stem}.R)"
        ) > {log} 2>&1
        """

rule manuscript:
    input:
        "abstract.tex",
        f"{MS}.tex",
        "main.tex",
        "supp.tex",
        FIG_OUTPUTS
    output:
        f"{MS}.pdf"
    shell:
        "cleantex -btq {MS}.tex"

        
