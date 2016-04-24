(use-package evil-leader
  :commands
  (evil-leader-mode global-evil-leader-mode)

  :config
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "q" 'delete-window
    "d" 'kill-this-buffer
    "s" 'save-buffer))

(use-package evil
  ;; all evil-want- variables go to init section
  :init
  (setq evil-want-C-u-scroll t)

  :config
  (global-evil-leader-mode)
  (evil-mode 1)

  (setq-default evil-shift-width 2)

  ;; a-la unimpaired
  (define-key evil-normal-state-map (kbd "]b") 'next-buffer)
  (define-key evil-normal-state-map (kbd "[b") 'previous-buffer)
  (define-key evil-normal-state-map (kbd "]q") 'next-error)
  (define-key evil-normal-state-map (kbd "[q") 'previous-error)

  ;; escape from anything
  (use-package evil-escape
    :config
    (evil-escape-mode)
    (global-set-key [escape] 'evil-escape))

  ;; gc for comments
  (use-package evil-commentary :config (evil-commentary-mode))

  ;; vim-surround clone
  (use-package evil-surround :config (global-evil-surround-mode 1)))

(provide 'my-evil)
