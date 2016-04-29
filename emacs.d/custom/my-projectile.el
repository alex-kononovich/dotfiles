(use-package projectile
  :config
  (projectile-global-mode)
  (add-hook 'evil-leader-mode-hook 'my-projectile-evil-leader-mode-hook))

(defun my-projectile-evil-leader-mode-hook ()
  (evil-leader/set-key
    "SPC" 'projectile-toggle-between-implementation-and-test
    "t" 'projectile-find-file
    "f" 'projectile-ag
    "b" 'projectile-switch-to-buffer
    "D" 'projectile-kill-buffers
    "ps" 'projectile-run-shell
    ;; <leader>p as prefix for all projectile bindings
    "p" 'projectile-command-map))

(provide 'my-projectile)
