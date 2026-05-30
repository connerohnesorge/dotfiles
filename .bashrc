
alias cfi='cd $(find . -type d -path "./.git" -prune -o -type d -not -path "*/\.*" -print | fzf --reverse --preview "ls --color {}")'
alias codex='codex --yolo'
alias cclds="claude --dangerously-load-development-channels plugin:firepit@pantheon-skills --dangerously-skip-permissions --model=sonnet $@"
alias ccldo="claude --effort=xhigh --dangerously-load-development-channels plugin:firepit@pantheon-skills --dangerously-skip-permissions --model='opus[1m]' $@"
alias ccldk="claude --dangerously-load-development-channels plugin:firepit@pantheon-skills --dangerously-skip-permissions --model=haiku $@"
alias cldo="claude --effort=xhigh --dangerously-skip-permissions --model='opus[1m]' $@"
alias clds="claude --dangerously-skip-permissions --model=sonnet $@"
alias cldk="claude --dangerously-skip-permissions --model=haiku $@"
alias nvimf='~/dotfiles/modules/programs/nvimf/nvimf'
alias nviml='~/dotfiles/modules/programs/nviml/nviml'
alias v='nvim $@'
