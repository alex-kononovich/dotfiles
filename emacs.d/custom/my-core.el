;; garbage collector threshold
(setq gc-cons-threshold 20000000)

;; don't ask about symlinks, just follow
(setq vc-follow-symlinks t)

(add-hook 'text-mode-hook 'visual-line-mode)

;; auto reload TAGS file
(setq tags-revert-without-query 1)

(provide 'my-core)
