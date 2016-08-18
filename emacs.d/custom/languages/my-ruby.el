;; ruby

(defun my-ruby-mode ()
  ;; treat _ as word character (Emacs don't do it by default, and Evil respects it)
  (modify-syntax-entry ?_ "w")
  ;; try to use correct ruby version
  (chruby-use-corresponding))

(add-hook 'ruby-mode-hook 'my-ruby-mode)


;; rspec

(defun my-rspec-verify-single ()
  "Run last spec in ruby files, and spec under point in RSpec files"
  (interactive)
  (if rspec-verifiable-mode
      (rspec-rerun)
    (rspec-verify-single)))

(defun do-not-truncate-lines ()
  (setq truncate-lines nil))

(use-package rspec-mode
  :commands (rspec-mode)
  :config
  (add-hook 'rspec-compilation-mode-hook 'do-not-truncate-lines)
  (evil-leader/set-key
    "rt" 'my-rspec-verify-single
    "rs" 'rspec-verify
    "ra" 'rspec-verify-all))


;; chruby

(use-package chruby
  :commands (chruby-use-corresponding))


;; projectile-rails

(use-package projectile-rails
  :commands (projectile-rails-on)
  :config
  (evil-leader/set-key
    "pP" 'rspec-verify-all))

(add-hook 'projectile-mode-hook 'projectile-rails-on)


;; bundler

(use-package bundler
  :commands (ruby-mode))


(provide 'my-ruby)
