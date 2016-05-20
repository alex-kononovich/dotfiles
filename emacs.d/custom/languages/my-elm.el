(use-package elm-mode
  :commands (elm-mode)
  :config
  (setq elm-indent-offset 4)
  (setq elm-tags-on-save t)
  (setq elm-format-on-save t))

(use-package flycheck-elm
  :commands (flycheck-elm-setup))

(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-elm-setup))

(provide 'my-elm)
