;; garbage collector threshold
(setq gc-cons-threshold 20000000)

;; don't ask about symlinks, just follow
(setq vc-follow-symlinks t)

(add-hook 'text-mode-hook 'visual-line-mode)

;; don't force me to type "yes"
(defalias 'yes-or-no-p 'y-or-n-p)

;; auto reload TAGS file
(setq tags-revert-without-query 1)

(use-package keyfreq
  :config
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

(provide 'my-core)
