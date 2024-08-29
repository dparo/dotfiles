;;; binds.el --- My custom keybinds                  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Davide Paro

;; Author: Davide Paro <dparo@dparo-pc>
;; Keywords: lisp



;; Binding keys
(require 'bind-key)



;; VS code like binds
(unbind-key "C-k")
(bind-key* "C-k k" 'kill-line)
(bind-key* "C-k C-k" 'kill-line)
(bind-key* "C-k [" 'origami-toggle-node)


(unbind-key "C-z")
(unbind-key "C-t")
(unbind-key "C-S-d")


(bind-key* "M-1" 'winum-select-window-1)
(bind-key* "M-2" 'winum-select-window-2)
(bind-key* "M-3" 'winum-select-window-3)
(bind-key* "M-4" 'winum-select-window-4)
(bind-key* "M-5" 'winum-select-window-5)
(bind-key* "M-6" 'winum-select-window-6)
(bind-key* "M-7" 'winum-select-window-7)
(bind-key* "M-8" 'winum-select-window-8)
(bind-key* "M-9" 'winum-select-window-9)

(bind-key* "<M-left>" 'windmove-left)
(bind-key* "<M-right>" 'windmove-right)
(bind-key* "<M-up>" 'windmove-up)
(bind-key* "<M-down>" 'windmove-down)


(bind-key* "<M-S-up>" 'recompile)
(bind-key* "<M-S-down>" 'window-toggle-side-windows)
(bind-key* "<M-S-right>" 'next-error)
(bind-key* "<M-S-left>" 'previous-error)


(bind-key* "C-=" 'zoom-in)
(bind-key* "C--" 'zoom-out)
(bind-key* "C-0" 'zoom-reset)


(bind-key "<f6>" 'window-toggle-side-windows)

(bind-key* "M-c c" 'recompile)
(bind-key* "M-<f7>" 'projectile-compile-project)
(bind-key* "<f7>" 'recompile)

(bind-key* "S-<f8>" 'previous-error)
(bind-key* "<f8>" 'next-error)


(unbind-key "M-m")
(bind-key* "M-m d" 'dap-debug-last)
(bind-key* "M-m c" 'window-toggle-side-windows)

(bind-key* "<f5>" 'dparo/cog)

;; (bind-key* "S-<f5>" 'dap-disconnect)
;; (bind-key* "<f5>" 'dap-continue)
;; (bind-key* "<f9>" 'dap-breakpoint-toggle)
;; (bind-key* "<f10>" 'dap-next)
;; (bind-key* "<f11>" 'dap-step-in)
;; (bind-key* "S-<f11>" 'dap-step-out)
;; (bind-key* "C-z" 'dap-eval)


(bind-key* "M-l r" 'lsp)
(bind-key* "<f1>" 'lsp-execute-code-action)
(bind-key* "<f2>" 'lsp-rename)
(bind-key* "<f12>" 'lsp-find-declaration)
(bind-key* "S-<f12>" 'lsp-find-definition)




(bind-key* "C-o" 'backward-global-mark)
(bind-key* "C-S-o" 'forward-global-mark)


(bind-key* "C-S-c" (lambda() (interactive)(find-file "~/.emacs.d/init.el")))



(bind-key* "C-p" 'counsel-fzf)
(bind-key* "C-S-p" 'projectile-find-file-other-window)
(bind-key* "C-S-f" 'counsel-projectile-ag)
(bind-key* "C-S-r" 'query-replace)
(bind-key* "C-S-s" 'swiper)
(bind-key* "C-S-h" 'counsel-projectile-replace)
(bind-key* "C-b" 'ivy-switch-buffer)
(bind-key* "C-S-b" 'ivy-switch-buffer-other-window)
(bind-key* "C-t" 'lsp-ivy-global-workspace-symbol)
(bind-key* "<C-backspace>" 'backward-kill-word)


(bind-key* "M-m m s" 'magit-status)
(bind-key* "M-m M-m s" 'magit-status)




;; (bind-key* "C-d" 'mc/mark-next-like-this-symbol)
;; (bind-key* "M-d" 'mc/unmark-next-like-this)
;; (bind-key* "C-u" 'mc/unmark-next-like-this)
;; (bind-key* "C-x SPC" 'set-rectangular-region-anchor)

(bind-key* "<C-M-up>" 'er/expand-region)

(define-key key-translation-map "\e[3?" [M-backspace])
(define-key key-translation-map "\e[5?" [C-backspace])
(define-key key-translation-map "\e[6?" [S-C-backspace])


(define-key key-translation-map "\e[1;2A" [S-up])
(define-key key-translation-map "\e[1;2B" [S-down])
(define-key key-translation-map "\e[1;2C" [S-right])
(define-key key-translation-map "\e[1;2D" [S-left])

(define-key key-translation-map "\e[1;5A" [C-up])
(define-key key-translation-map "\e[1;5B" [C-down])
(define-key key-translation-map "\e[1;5C" [C-right])
(define-key key-translation-map "\e[1;5D" [C-left])

(define-key key-translation-map "\e[1;6A" [S-C-up])
(define-key key-translation-map "\e[1;6B" [S-C-down])
(define-key key-translation-map "\e[1;6C" [S-C-right])
(define-key key-translation-map "\e[1;6D" [S-C-left])

(define-key key-translation-map "\e[1;3A" [M-up])
(define-key key-translation-map "\e[1;3B" [M-down])
(define-key key-translation-map "\e[1;3C" [M-right])
(define-key key-translation-map "\e[1;3D" [M-left])


(define-key key-translation-map "\e[1;4A" [M-S-up])
(define-key key-translation-map "\e[1;4B" [M-S-down])
(define-key key-translation-map "\e[1;4C" [M-S-right])
(define-key key-translation-map "\e[1;4D" [M-S-left])
