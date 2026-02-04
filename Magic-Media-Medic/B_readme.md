 vibe coding: Media Recovery Suite
vibe coding is a collection of smart, context-aware scripts designed to fix media libraries that have lost their file extensions during data recovery or failed migrations.

Instead of just guessing extensions, these scripts use a multi-layered validation cascade (Magic Bytes + Path Context + Archive Deep-Scan) to ensure your 3TB library returns to a pristine state without manual grunt work.

 The Core Tool: Bv1_scanner.sh
The Bv1_scanner.sh is the forensic heart of this suite. It doesn't just rename files; it analyzes them.

Key Features:
Resume-Sync: Interrupted a scan? No problem. The script remembers where it left off.

Contextual Intelligence: Knows that a zip file in a /Books/ folder is likely an epub.

Deep-Scan (Ninja Mode): Peeks inside archives (ZIP/RAR) without extracting them to identify their true nature (e.g., finding the mimetype file inside an EPUB).

Safety First: Generates a CSV diagnosis before making any changes. You stay in control.

 How to Use
1. Diagnosis
Configure your TARGET_DIR in the script and run:

Bash

bash Bv1_scanner.sh
This produces todo_Bv1_diagnose.csv, a full report of every "problem child" in your library.

2. Analysis
Check your stats with a quick one-liner:

Bash

cut -d';' -f5 todo_Bv1_diagnose.csv | sort | uniq -c | sort -nr
3. Repair (Coming Soon)
The upcoming Bv1_medic.sh will take your CSV and perform the surgery, renaming thousands of files in seconds while logging every success.

 The Logic Cascade
The scanner evaluates files in this order:

Magic Bytes: Identifying the container (Matroska, ISO Media, XML).

File Suffix: Checking what the filename claims to be (e.g., _mkv).

Path Context: Checking if the file resides in Music, Video, or Ebook directories.

Internal Structure: Using unzip -l to verify internal file signatures.

🤝 Contributing
This is part of the vibe coding philosophy: keeping scripts lean, effective, and slightly witty. Feel free to open an issue or PR if you have a new "Deep-Scan" idea for a tricky file format.
