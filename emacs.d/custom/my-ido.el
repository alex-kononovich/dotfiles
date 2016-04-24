(ido-mode 1)
(ido-everywhere 1)

;; use ido in most places
(use-package ido-ubiquitous :config (ido-ubiquitous-mode 1))

;; fuzzy matching
(use-package flx-ido :config (flx-ido-mode 1))

;; vertical mode
(use-package ido-vertical-mode
  :config
  (ido-vertical-mode 1)
  ;; move with C-n and C-p
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

;; M-x with ido
(use-package smex :config (global-set-key (kbd "M-x") 'smex))

;; bind my custom keys to ido minibuffer
(add-hook 'ido-setup-hook 'my-ido-setup)

(require 'ido-other-window)

(defun my-ido-setup ()
  ;; very convinient in case of typos
  (define-key ido-completion-map (kbd "C-w") 'backward-kill-word)
  ;; remap some ido-other-window
  (define-key ido-completion-map (kbd "C-o") 'ido-invoke-in-other-window)
  (define-key ido-completion-map (kbd "C-s") 'ido-invoke-in-vertical-split)
  (define-key ido-completion-map (kbd "C-v") 'ido-invoke-in-horizontal-split))

(provide 'my-ido)
