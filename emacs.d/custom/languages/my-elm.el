(use-package elm-mode
  :commands (elm-mode)
  :config
  (setq elm-indent-offset 4)
  (setq elm-tags-on-save t)
  (setq elm-format-on-save t))

(provide 'my-elm)
