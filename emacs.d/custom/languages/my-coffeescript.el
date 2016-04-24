(use-package coffee-mode
  :commands (coffee-mode))

(add-to-list 'auto-mode-alist '("\\.cjsx\\'" . coffee-mode))

(provide 'my-coffeescript)
