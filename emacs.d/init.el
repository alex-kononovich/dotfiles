;; packages

(setq package-list '(evil solarized-theme))

(require 'package)

(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; disable startup screen
(setq inhibit-startup-screen t)

;; visual
(load-theme 'solarized-light t)
(set-frame-font "Menlo-15" nil t)
(setq x-underline-at-descent-line t)
(set-scroll-bar-mode nil)

;; start fullscreen (note fullscreen instead of fullboth - it's special feature of emacs-mac)
(set-frame-parameter nil 'fullscreen 'fullscreen)

;; evil must go after all packages
(require 'evil)
(evil-mode 1)
