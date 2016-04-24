(use-package magit
  :config
  ;; use default bindings for blame mode
  (add-hook 'magit-blame-mode-hook 'evil-emacs-state)
  ;; start commit message in insert mode
  (add-hook 'git-commit-mode-hook 'evil-insert-state)
  ;; use ido to complete things like branches
  (setq magit-completing-read-function 'magit-ido-completing-read)
  ;; wait for evil-leader to setup bindings
  (add-hook 'evil-leader-mode-hook 'my-magit-evil-leader-mode-hook))

(use-package magit-gitflow
  :config
  (add-hook 'magit-mode-hook 'turn-on-magit-gitflow))

(defun my-magit-evil-leader-mode-hook ()
  (evil-leader/set-key
    "gs" 'magit-status
    "gl" 'magit-log-current
    "gw" 'magit-stage-file
    "gc" 'magit-commit
    "gb" 'magit-blame))

(provide 'my-magit)
