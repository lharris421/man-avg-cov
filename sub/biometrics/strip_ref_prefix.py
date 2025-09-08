#!/usr/bin/env python3
"""
strip_ref_prefix.py
-------------------
*   Collect every \label{...} defined in supp.tex.
*   In main.tex **and** supp.tex, replace occurrences of
        Figure~\ref{label}, Fig.~\ref{label}, Table~\ref{label},
        Alg.~\ref{label} (or Alg\ref{label})
    **only when `label` was defined in supp.tex**,
    leaving just \ref{label}.
*   Creates *.bak backups of the originals.
"""

import re
from pathlib import Path
import sys

# ---------------------------------------------------------------------------
# 1. Harvest labels from supp.tex
# ---------------------------------------------------------------------------
supp_path = Path("supp.tex")
if not supp_path.exists():
    sys.exit("supp.tex not found – are you in sub/biometrics/?")

supp_labels = set(re.findall(r"\\label\{([^}]*)\}", supp_path.read_text()))

if not supp_labels:
    print("No labels found in supp.tex – nothing to do.")
    sys.exit(0)

# ---------------------------------------------------------------------------
# 2. Prepare regex and replacement callback
# ---------------------------------------------------------------------------
# Matches Figure~/Fig./Table~/Alg.~ followed by \ref{...}
prefix_pat = re.compile(
    r"\b(?:Figure|Fig\.|Table|Alg\.?)~\\ref\{([^}]*)\}"
)

def drop_prefix(match: re.Match) -> str:
    """Return \ref{label} if the label came from supp.tex, else leave unchanged."""
    label = match.group(1)
    return rf"\ref{{{label}}}" if label in supp_labels else match.group(0)

# ---------------------------------------------------------------------------
# 3. Patch main.tex and supp.tex in place (with .bak backups)
# ---------------------------------------------------------------------------
for tex_file in ("main.tex", "supp.tex"):
    path = Path(tex_file)
    if not path.exists():
        print(f"⚠️  {tex_file} not found – skipped.")
        continue

    original = path.read_text()
    modified = prefix_pat.sub(drop_prefix, original)

    if original == modified:
        print(f"✓ {tex_file} already clean.")
        continue

    backup = path.with_suffix(path.suffix + ".bak")
    backup.write_text(original)       # keep a backup
    path.write_text(modified)         # overwrite with cleaned version
    print(f"✓ {tex_file} cleaned (backup → {backup.name})")
