(set-frame-font "Menlo-15" nil t)

(use-package solarized-theme
  :config
  (load-theme 'solarized-light t)
  (load-theme 'solarized-dark t)
  (setq x-underline-at-descent-line t))

;; disable startup screen
(setq inhibit-splash-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-message t)

;; no scrollbar
(set-scroll-bar-mode nil)

;; no toolbar
(tool-bar-mode nil)

;; start fullscreen (note fullscreen instead of fullboth - it's
;; a special feature of emacs-mac, native mac os fullscreen)
(set-frame-parameter nil 'fullscreen 'fullscreen)

;; truncate lines
(setq-default truncate-lines t)

(provide 'my-eyecandy)
