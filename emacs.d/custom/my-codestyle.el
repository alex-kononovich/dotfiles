;; use spaces for indentation
(setq-default indent-tabs-mode nil)

;; 80 columns by default
(setq-default fill-column 80)

;; automatically clear trailing whitespaces, but only on lines I've edited
;; (don't be a "whitespace police")
(use-package ws-butler :config (ws-butler-global-mode 1))

(provide 'my-codestyle)
