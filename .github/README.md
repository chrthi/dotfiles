To install, do:
```bash
cd "$HOME"
git clone --bare 'https://github.com/chrthi/dotfiles.git' dotfiles
cd dotfiles
git config --local --type bool core.bare false
git config --local --path core.worktree "$HOME"
git reset --mixed main
```
