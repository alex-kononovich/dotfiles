(use-package coffee-mode
  :mode (("\\.cjsx$" . coffee-mode))
  :commands (coffee-mode)
  :config
  (custom-set-variables '(coffee-tab-width 2)))

(provide 'my-coffeescript)
