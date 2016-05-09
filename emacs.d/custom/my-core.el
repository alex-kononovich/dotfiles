;; garbage collector threshold
(setq gc-cons-threshold 20000000)

;; don't ask about symlinks, just follow
(setq vc-follow-symlinks t)

(add-hook 'text-mode-hook 'visual-line-mode)

(provide 'my-core)
