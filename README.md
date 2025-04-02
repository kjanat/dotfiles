# Dotfiles Bootstrap & Setup Scripts

This folder contains platform-agnostic scripts to bootstrap and configure your personal dotfiles setup across:

- **Linux** (bash/zsh/fish)
- **Windows** (PowerShell / WSL)
- **FreeBSD / TrueNAS** (csh/tcsh)

> [!NOTE]
> 
> Your actual dotfiles are managed separately at [kjanat/dotfiles](https://github.com/kjanat/dotfiles).  
These scripts clone and configure that repo as a bare Git repo in `~/.dotfiles`.

---

## Usage

### 1. Bootstrap your dotfiles

```bash
./bootstrap
```

This script auto-detects your shell and runs the correct bootstrap for:

- bash/zsh (bootstrap.sh)
- PowerShell (bootstrap.ps1)
- csh (bootstrap.csh)

It will:

- Clone your dotfiles from kjanat/dotfiles
- Backup any conflicting files
- Set up your home dir with your configs

---

2. Set up your shell and tooling

```bash
./setup
```

This script:

- Adds the dotfiles Git alias to your shell config
- Installs common tools (git, zsh, vim, etc.)
- Optionally sets your shell to zsh

---

Directory structure

```plaintext
dotfiles/
├── bootstrap*       → universal bootstrap dispatcher
├── bootstrap.sh     → bash/zsh installer
├── bootstrap.ps1    → PowerShell installer
├── bootstrap.csh    → csh installer
├── setup*           → universal setup dispatcher
├── setup.sh         → bash/zsh tooling
├── setup.ps1        → PowerShell tooling
├── setup.csh        → csh tooling
└── README.md        → this file
```

Make the scripts executable:

```bash
chmod +x bootstrap bootstrap.sh setup setup.sh
```

---

### Related

[kjanat/dotfiles](kjanat/dotfiles) – your actual config repo

---

### [`kjanat/kjanat/dotfiles/.gitignore`](dotfiles/.gitignore)

```gitignore
# Backup and temp folders
*.swp
*~
.DS_Store
*.bak
*.old

# Dotfiles boot artifacts (not needed in repo)
dotfiles-backup/
```
