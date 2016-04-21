;; initialize use-package
(require 'package)
(package-initialize)
(setq package-enable-at-startup nil)

(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; visual
(set-frame-font "Menlo-15" nil t)
(set-scroll-bar-mode nil)
(use-package solarized-theme
  :ensure solarized-theme
  :config
  (progn
    (load-theme 'solarized-light t)
    (setq x-underline-at-descent-line t)))

;; disable startup screen
(setq inhibit-startup-screen t)

;; start fullscreen (note fullscreen instead of fullboth - it's
;; a special feature of emacs-mac)
(set-frame-parameter nil 'fullscreen 'fullscreen)

;; git
(use-package magit :ensure magit)

;; indentation settings
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; evil must go after all packages
(use-package evil
  :ensure evil
  :init
  (progn
    (setq evil-want-C-u-scroll t)
    (setq evil-shift-width 2))
  :config (evil-mode 1))
