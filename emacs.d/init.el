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
(setq use-package-always-ensure t)

;; garbage collector threshold
(setq gc-cons-threshold 20000000)

;; visual
(set-frame-font "Menlo-15" nil t)
(set-scroll-bar-mode nil)
(use-package solarized-theme
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
(use-package magit
  :config
  (progn
    (evil-leader/set-key
      "gs" 'magit-status)))

;; indentation settings
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

;; 80 columns by default
(setq-default fill-column 80)

;; ag
(use-package ag)

;; projectile
(use-package projectile
  :config
  (progn
    (projectile-global-mode)
    (evil-leader/set-key
      "t" 'projectile-find-file
      "f" 'projectile-ag
      "pp" 'projectile-switch-project)))

;; ido
(ido-mode 1)
(ido-everywhere 1)
;; use ido in most places
(use-package ido-ubiquitous :config (ido-ubiquitous-mode 1))
;; fuzzy matching
(use-package flx-ido :config (flx-ido-mode 1))
;; vertical mode
(use-package ido-vertical-mode
  :config
  (progn
    (ido-vertical-mode 1)
    ;; move with C-n and C-p
    (setq ido-vertical-define-keys 'C-n-and-C-p-only)))

;; evil-leader
(use-package evil-leader
  :config
  (progn
    (evil-leader/set-leader "<SPC>")
    (evil-leader/set-key
      "b" 'switch-to-buffer
      "q" 'kill-buffer-and-window
      "d" 'kill-this-buffer
      "s" 'save-buffer)))

;; evil must go after all packages
(use-package evil
  :init
  (progn
    (setq evil-want-C-u-scroll t)
    (setq evil-shift-width 2))
  :config
  (progn
    (global-evil-leader-mode)
    (evil-mode 1)))
