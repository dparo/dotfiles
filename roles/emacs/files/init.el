(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


;; Do not load Xresources. This fixes the cursor color being different in emacs daemon vs a normal emacs client
(setq inhibit-x-resources t)


(setq custom-file (concat user-emacs-directory "custom.el"))
(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))
(setq create-lockfiles nil)
(setq make-backup-files nil)


(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/saves/" t)))
(setq-default auto-save-file-name-transforms `((".*" "~/.emacs.d/saves/" t)))
(setq auto-save-default nil)
(setq-default auto-save-default nil)
(setq auto-save-interval 0)
(setq-default auto-save-interval 0)
(setq auto-save-timeout 0)
(setq-default auto-save-timeout 0)
(setq-default create-lockfiles nil)
(setq-default make-backup-files nil)


(defalias 'yes-or-no-p 'y-or-n-p)

(use-package crux)
(use-package diff-hl
  :config
  (global-diff-hl-mode +1))


(use-package git-commit)

;; Programming languages mode
(use-package rust-mode)
(use-package go-mode)
(use-package cmake-mode)
(use-package meson-mode)
(use-package julia-mode)
(use-package ess)     ;; For R-lang

(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.25)
  :hook
  (text-mode . highlight-symbol-mode)
  )

;; Folding support in emacs
(use-package origami
  :hook
  (prog-mode . origami-mode)
  )

(use-package cargo
  :after rust-mode
  :hook
  (rust-mode . cargo-minor-mode))


(use-package edit-indirect)
(use-package markdown-mode

  ;; NOTE: Use mostly github flavoured markdown (gfm-mode) since it supports
  ;; underscore in between letters without generating underscores:
  ;; example: `my_little_variable` will not be underscored
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))

  :init
  (setq markdown-command '("pandoc" "--from=markdown" "--to=html5"))
  (setq markdown-open-image-command "imv-x11")
  :config
  (setq markdown-enable-math t)
  (setq-default markdown-enable-math t)
  (setq markdown-header-scaling t)
  (setq-default markdown-header-scaling t)
  (setq markdown-enable-wiki-links t)
  (setq-default markdown-enable-wiki-links t)
  (setq markdown-fontify-code-blocks-natively t)
  (setq-default markdown-fontify-code-blocks-natively t))


(use-package fish-mode)

(use-package lua-mode)
(use-package yaml-mode)
(use-package toml-mode)

(use-package sudo-edit)

(use-package ansi-color
  :config
  (require 'ansi-color)
  (defun colorize-compilation-buffer ()
    ;(toggle-read-only)
    (ansi-color-apply-on-region compilation-filter-start (point-max))
    ;(toggle-read-only)

    )
  (add-hook 'compilation-filter-hook 'colorize-compilation-buffer))

(use-package beacon
  :config
  (setq beacon-push-mark 35)       ;; If the jump is bigger than N, than push the mark
  :hook
  (prog-mode . beacon-mode)
  )

(use-package js2-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.mjs\\'" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))
  )

;; For javascript development: Node.js OR Chrome debugger attachnent, console and REPL
(use-package indium)
;; js-comint: send to node.js REPL
(use-package js-comint)

(use-package json-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
  )


(use-package typescript-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
  )


(use-package find-file
  :config
  (setq ff-always-in-other-window t)
  (setq ff-always-try-to-create t)
  (setq cc-search-directories '("." "../src" "../source" "../include" "/usr/include" "/usr/local/include/*"))
  :bind
  ("<C-tab>" . ff-find-other-file)
  )


(use-package modus-vivendi-theme :ensure t :defer t)
(use-package vscode-dark-plus-theme :ensure t :defer t)
(use-package ample-theme :ensure t :defer t)
(use-package nimbus-theme :ensure t :defer t)
(use-package gruvbox-theme :ensure t :defer t)

;; Generic packages usefull in every scenario
(use-package monokai-theme
  :ensure t
  :defer t
  :config
  (set-cursor-color "#00ff7f")
  (setq default-frame-alist '((cursor-color . "#00ff7f")))
  )


(use-package ag
  :config
  (setq ag-arguments '("--smart-case" "--stats" "--follow"))
  )
(use-package rg)
(use-package ace-window
  :bind
  ("M-o" . ace-window)
  )

(use-package ivy
  :config
  (ivy-mode 1)
  )


(use-package swiper)
(use-package counsel)

;; (use-package multiple-cursors
;;   :after (company lsp lsp-ui)
;;   :config
;;   (require 'multiple-cursors)

;;   :bind
;;   ("C-d".  mc/mark-next-like-this-symbol)
;;   ("M-d" . mc/unmark-next-like-this)
;;   ("C-x SPC" . set-rectangular-region-anchor)
;;   :bind (:map mc/keymap
;;           ("<return>" . nil)
;;           ("ESC ESC" . mc/keyboard-quit)
;;           )
;;   )


;; (use-package helm
;;   :init
;;   (helm-mode +1)
;;   :bind
;;   ("M-x" . helm-M-x)
;;   ("C-x C-f" . helm-find-files)
;;   :bind (:map helm-map

;;            ("TAB" . #'helm-execute-persistent-action))
;;   )

;; (use-package popwin
;;   :config
;;   ;; (setq display-buffer-function 'popwin:display-buffer)
;;   ;; (push '("^\*helm .+\*$" :regexp t) popwin:special-display-config)
;;   ;; (push '("^\*helm-.+\*$" :regexp t) popwin:special-display-config)
;; )


(use-package undo-fu
  :bind
  ("C-S--" . undo-fu-only-undo)
  ("M-_" . undo-fu-only-redo))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  )


;; COG stuff.
(defun dparo/cog ()
  (interactive)
  (save-buffer)
  (call-process "python3" nil (get-buffer-create "cog-msgs") nil "-m" "cogapp" "-r" (buffer-file-name))
  (revert-buffer nil t))


(defun dparo/modeline-reset ()
  "Resets and redraw the modeline"
  (interactive)


  (let* ((height (face-attribute 'default :height))
         (modeline-font-ratio 0.8)
         (modeline-height (truncate (* height modeline-font-ratio))))

    (set-face-attribute 'mode-line nil :family (face-attribute 'default :family) :height modeline-height)
    (set-face-attribute 'mode-line-inactive nil :family (face-attribute 'default :family) :height modeline-height)
    (setq doom-modeline-height 1)
    (doom-modeline-refresh-font-width-cache)
    (doom-modeline-refresh-bars)
    (doom-modeline-redisplay)
    )
  )

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (doom-modeline-mode 1)
  (dparo/modeline-reset)
  )


(use-package winum
  :config
  (winum-mode +1)
  )

(defun dparo/append-projectile-dir (dir)
  "Add dir to the search path of projectile to discover available projects."
  (if (file-directory-p dir) (push dir projectile-project-search-path))
  )

;; Useful packages for development
(use-package projectile
  :requires ivy
  :custom
  (projectile-completion-system 'ivy)
  :config

  (dparo/append-projectile-dir "~/git-clone")
  (dparo/append-projectile-dir "~/Dropbox/develop")
  (dparo/append-projectile-dir "~/Dropbox/UniversityProjects")
  (dparo/append-projectile-dir "~/develop")
  (projectile-discover-projects-in-search-path)
  )

(use-package smex)


(use-package counsel-projectile
  :requires projectile smex
  :bind
  )

(use-package company
  :hook
  (prog-mode . company-mode)
  (latex-mode . company-mode)
  (LaTeX-mode . company-mode)
  (tex-mode . company-mode)
  (TeX-mode . company-mode)
  (company-mode . company-tng-mode)


  :bind (:map company-active-map
          ("RET" . nil)
          ("C-j" . company-complete-selection)
          ("<up>" . nil)
          ("<down>" . nil)
          )
  :config
  (setq company-idle-delay 0.25)
  (setq company-dabbrev-code-time-limit 0.25)
  (setq company-dabbrev-time-limit 0.25)

  (setq company-dabbrev-downcase 0)
  (setq company-dabbrev-ignore-case 1)
  (setq company-require-match nil)
  (setq company-minimum-prefix-length 1)
  (setq company-clang-insert-arguments t)

  (add-to-list 'company-backends 'company-files)
  )

(use-package prescient
  :config
  (prescient-persist-mode +1))

(use-package ivy-prescient
  :after ivy
  :config
  (ivy-prescient-mode 1))

(use-package company-prescient
  :after company
  :config
  (company-prescient-mode 1))


;; For editing jupyter notebooks
(use-package ein)


(defun dired-open-rifle ()
  "Try to run `xdg-open' to open the file under point."
  (interactive)
  (if (executable-find "rifle")
      (let ((file (ignore-errors (dired-get-file-for-visit))))
        (start-process "rifle-open" nil
                       "rifle" (file-truename file)))
    nil))

(use-package dired-open
  :config


  ;; When pressing from dired, it will always run the rifle way of visiting files.
  ;; (add-to-list 'dired-open-functions #'dired-open-rifle)
  (setq dired-open-extensions '(("png" . "rifle")
                                ("jpg" . "rifle")
                                ("jpeg" . "rifle")
                                ("bmp" . "rifle")
                                ("mkv" . "rifle")
                                ("mp4" . "rifle"))))


(use-package all-the-icons)

;;;; Disabled cause it is kinda weird, and makes the buffer less readable with tab-mode displayed
;; (use-package all-the-icons-dired
;;   :hook
;;   (dired-mode . all-the-icons-dired-mode))

;; (use-package dashboard
;;   :after (all-the-icons org projectile)
;;   :if (< (length command-line-args) 2)
;;   :config
;;   (dashboard-setup-startup-hook)
;;   (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
;;   (setq dashboard-startup-banner (concat user-emacs-directory "logos/math1.png"))
;;   (setq dashboard-center-content t)
;;   (add-to-list 'dashboard-items '(agenda) t)
;;   (setq show-week-agenda-p t)
;;   )

;; (use-package company-box
;;   :after all-the-icons
;;   :hook
;;   (company-mode . company-box-mode))

(use-package which-key
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5)
  )


(use-package expand-region
  :config
  (require 'expand-region))

(use-package yasnippet
  :after company
  :config
  (yas-global-mode +1)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "C-j") yas-maybe-expand)
  (define-key yas-minor-mode-map (kbd "C-c y") #'yas-expand)
  )


;; Use PCRE regexp please. Thank you
(use-package pcre2el
  :config
  (rxt-global-mode 1)
  )


(use-package yasnippet-snippets
  :after
  yasnippet)


(if (functionp 'module-load)
    (progn
      ;; Use TreeSitter (A Rust library) to provide syntax hightlight instead
      ;; of the shitty EMACS font-lock-mode which is based on regexp. Unfortenately
      ;; This requires emacs to be built with modules support (--with-modules)
      (use-package tree-sitter
        :config
        (global-tree-sitter-mode)
        (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
        )
      (use-package tree-sitter-langs)
      )
  )

;; (defun dparo/sp-insert-only-if (_id action _context)
;;   (or
;;    (sp-in-string-p _id action _context)
;;    (sp-in-comment-p _id action _context)

;;    (sp-point-before-word-p _id action _context)
;;    (sp-point-before-same-p "(" action _context)
;;    (sp-point-before-same-p "[" action _context)
;;    (sp-point-before-same-p "{" action _context)
;;    (sp-point-before-same-p "'" action _context)
;;    (sp-point-before-same-p "\"" action _context)))

;; (use-package smartparens
;;   :hook
;;   (prog-mode . smartparens-mode)
;;   :config
;;   (require 'smartparens-config)

;;   (setq sp-highlight-pair-overlay nil)

;;   ;; https://smartparens.readthedocs.io/en/latest/permissions.html#filters
;;   (sp-pair "(" nil :unless '(dparo/sp-insert-only-if))
;;   (sp-pair "[" nil :unless '(dparo/sp-insert-only-if))
;;   (sp-pair "{" nil :unless '(dparo/sp-insert-only-if))
;;   (sp-pair "\"" nil :unless '(dparo/sp-insert-only-if))
;;   (sp-pair "'" nil :unless '(dparo/sp-insert-only-if))
;;   (sp-pair "\\'" nil :unless '(dparo/sp-insert-only-if))
;;   )

;; (use-package autopair
;;   :config
;;   (setq autopair-blink nil)
;;   (setq autopair-skip-whitespace t) ;; when set to non-nil, tells autopair to skip over whitespace when attempting to skip over a closing brace. If you set this to 'chomp, the whitespace is not only jumped over but also deleted
;;   :hook
;;   (prog-mode . autopair-mode)
;;   )


(use-package clang-format+
  :config
  (setq clang-format+-always-enable nil)         ;; If t, always reformat even if .clang_format is not present
  (setq clang-format+-context 'definition)
  ;;:hook
  ;;(c-mode . 'clang-format+-mode)
  ;;(c++-mode . 'clang-format+-mode)
  )

(use-package flycheck
  :config
  (setq flycheck-idle-change-delay 0.5)
  :hook
  (prog-mode . flycheck-mode)
  )

(use-package treemacs
  :bind
  ("C-S-t" . treemacs)
  )
(use-package magit)
(use-package forge
  :after magit)


(use-package lsp-treemacs
  :after lsp-mode
  :config
  (lsp-treemacs-sync-mode 0))


(use-package dap-mode
  :config
  (setq lsp-enable-dap-auto-configure t)
  (setq dap-auto-configure-features '(ui expressions locals controls tooltip breakpoints))

  (require 'dap-python)
  (require 'dap-cpptools)
  (require 'dap-firefox)
  (require 'dap-node)

  (progn
    (dap-cpptools-setup)
    (dap-firefox-setup)
    (dap-node-setup)
    )
  )


;; Eclipse like CTRL+T functionality to jump to definitions of types by search
(use-package lsp-ivy
  :after lsp-mode)

(use-package ccls
  :after lsp-mode
  :config
  (require 'ccls)
  )


(use-package lsp-mode
  :config

  (setq lsp-breadcrumb-enable nil)
  (setq-default lsp-breadcrumb-enable nil)
  (lsp-headerline-breadcrumb-mode 0)

  ;; Other linters which are not supported from this LSP package are:
  ;;      these packages are usually supported by CMD line usage, or throught flycheck/flymake
  ;;      but do not support the LANGUAGE SERVER PROTOCOL
  ;; - pychecker: (another older tool - not support by LSP). --- http://pychecker.sourceforge.net/
  ;; - mypy: Written in Python. Static type checker which supports decorators on function return values and arguments to "describe" the expected type
  ;;         Microsoft pyright is an equivalent choice supporting the LSP protocol
  ;;         --- https://github.com/python/mypy
  (setq lsp-enable-snippet t)

  ;; Another linter. Compared to flake8 is slower and provides more __FALSE POSITIVES__.
  ;; But sometimes it can report more errors compared to flake8. So we might use them
  ;; both at the same time.
  (setq lsp-pyls-plugins-pylint-enabled t)
  ;; Combines pyflakes and pycodestyle to provide both common error in source code
  ;; and style violations
  (setq lsp-pyls-plugins-flake8-enabled t)
  ;; Pyflakes isa plugin for flake 8. The docs says it is faster than pylint and pychecker
  ;; This alone does not check for any style issue
  ;; Disabling it makes flake8 pretty useless.
  (setq lsp-pyls-plugins-pyflakes-enabled t)

  ;; Yapf is a python formatter made by google
  (setq lsp-pyls-plugins-yapf-enabled t)

  ;; pycodestyle is a checker that checks if the source code is formatted according to PEP8.
  ;; autopep8 is a formatter using pycodestyle that guarantess that after the formatting
  ;; pycodestyle will not report any more error
  (setq lsp-pyls-plugins-autopep8-enabled nil)
  ;; Used by flake8. Disable it if you don't want to use it from flake8.
  (setq lsp-pyls-plugins-pycodestyle-enabled t)

  ;; Plugin for flake8. It implements McCabe complexity. That is it can emit
  ;; warnings when code becomes too complex. It thus can provide
  ;; a good measure when a function is too complex and it must be refactored
  (setq lsp-pyls-plugins-mccabe-enabled nil)


  (setq lsp-pyls-configuration-sources ["pycodestyle" "flake8" "pylintrc"])

  (setq lsp-idle-delay 0.5)
  (setq lsp-restart 'ignore)
  (setq lsp-clients-clangd-args '("--clang-tidy" "--background-index"))
  (add-to-list 'lsp-disabled-clients 'bash-ls)


  (add-to-list 'lsp-file-watch-ignored  "[/\\\\]build\\'")
  (add-to-list 'lsp-file-watch-ignored  "[/\\\\]build-release\\'")
  (add-to-list 'lsp-file-watch-ignored  "[/\\\\]build-debug\\'")
  (add-to-list 'lsp-file-watch-ignored  "[/\\\\]dist\\'")


  :hook
  (prog-mode . lsp)
  (latex-mode . lsp)
  (LaTeX-mode . lsp)
  (tex-mode . lsp)
  (TeX-mode . lsp)

  ;; breadcumb mode generates an IDE-like status line at the top showing in which file -> class -> method that we are in
  ;;(lsp-mode . lsp-headerline-breadcrumb-mode)
  (lsp-mode . lsp-lens-mode)
  (lsp-mode . lsp-enable-which-key-integration)
  (lsp-mode . (lambda ()
        (remove-hook 'before-save-hook #'lsp-format-buffer t)
        (remove-hook 'before-save-hook #'lsp-organize-imports t)))
  )

(use-package auctex
  :defer t
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-PDF-mode t)
  (setq-default TeX-master nil)

  (setq TeX-command-default "LatexMk")

  (setq TeX-view-program-selection
    '((output-dvi "DVI Viewer")
      (output-pdf "PDF Viewer")
      (output-html "HTML Viewer")))
  (setq TeX-view-program-list
    '(("DVI Viewer" "evince %o")
      ("PDF Viewer" "zathura %o")
      ("HTML Viewer" "firefox %o")))
  )

(use-package auctex-latexmk
  :after auctex)


(use-package company-auctex
  :after company
  )

(use-package lsp-ui
  :requires lsp-mode
  :config
  (setq lsp-ui-doc-show-with-mouse t)       ;; When the mouse goes over the symbol do not show docs
  (setq lsp-ui-doc-show-with-cursor t)      ;; When the typing cursor goes over the symbol show docs
  (setq track-mouse nil)                    ;; Reset back to not track since lsp activates it
  :hook
  (lsp-mode . lsp-ui-mode)
  (lsp-ui-mode . (lambda () (setq track-mouse nil))))


;; Package from microsoft: https://github.com/microsoft/pyright
;; Written in typescript
;; Provides common static deducable type checking errors in python code.
;; It supports typesheds (https://github.com/python/typeshed)
;; that is markup decorators types that can be provided to function arguments
;; or function return values in order to help the type checker
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
             (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred
(use-package lsp-latex
  :hook
  (latex-mode . (lambda ()
            (require 'lsp-latex)
            (lsp)))
  (tex-mode . (lambda ()
        (require 'lsp-latex)
        (lsp)))
  (LaTeX-mode . (lambda ()
          (require 'lsp-latex)
          (lsp)))
  (TeX-mode . (lambda ()
        (require 'lsp-latex)
        (lsp)))
  :config
  (setq tex-directory "~/.cache/emacs/tex-dir")
  )

(use-package python-mode
  :config
  (setq python-shell-completion-native-enable nil)
  (setq python-shell-interpreter "python3")
  :hook
  (python-mode . (lambda () (add-to-list 'company-backends 'company-jedi)))
  )


(use-package graphviz-dot-mode
    :mode (("\\.diag\\'"      . graphviz-dot-mode)
           ("\\.blockdiag\\'" . graphviz-dot-mode)
           ("\\.nwdiag\\'"    . graphviz-dot-mode)
           ("\\.rackdiag\\'"  . graphviz-dot-mode)
           ("\\.dot\\'"       . graphviz-dot-mode)
           ("\\.gv\\'"        . graphviz-dot-mode))
    :config
    :hook
    (graphiv-dot-mode . graphviz-turn-on-live-preview))


(use-package lice
  :config
  (setq lice:default-license "mit")
  )

(use-package hl-todo
  :hook
  (prog-mode . hl-todo-mode))


(use-package org-projectile
  :after (projectile org)
  :config
  (org-projectile-per-project)
  (setq org-projectile-per-project-filepath "todos.org")
  (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))

  :bind
  ("C-c c" . 'org-capture)
  ("C-c n p" . 'org-projectile-project-todo-completing-read)
  )


(use-package org
  :ensure org-plus-contrib
  :config

  (require 'org-tempo)
  (require 'rx)
  (define-obsolete-function-alias 'org-define-error 'define-error)

  (if (file-directory-p "~/Dropbox/org")
      (progn
        (setq org-directory "~/Dropbox/org")
        (setq org-agenda-files '("~/Dropbox/org")))
    (progn
      (setq org-directory "~/org")
      (setq org-agenda-files '("~/org"))))

  (setq org-babel-python-command "python3")
  (setq org-export-babel-evaluate nil)
  (setq org-export-html-validation-link nil)
  (setq org-html-validation-link nil)
  (setq org-html-htmlize-output-type 'css)
  (setq org-support-shift-select 'always)
  (setq org-catch-invisible-edits 'error)

  (setq org-preview-latex-default-process 'dvipng) ;; You can also try with 'imagemagick but it does not seem to work
  (setq org-format-latex-options '(:foreground default :background default :scale 2.0 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
                                               ("begin" "$1" "$" "$$" "\\(" "\\[")))

  (setq org-preview-latex-image-directory "~/.cache/emacs/ltximg")
  (setq org-latex-preview-ltxpng-directory "~/.cache/emacs/ltximg")

  (setq org-babel-default-header-args '((:session . "none")             ; Use session nil to use sessions by default (do not work for some reason)
                                        (:results . "replace")
                                        (:exports . "code")
                                        (:cache . "no")
                                        (:noweb . "no")
                                        (:hlines . "no")
                                        (:tangle . "no")))

  (setq org-confirm-babel-evaluate nil)
  (setq-default org-confirm-babel-evaluate nil)


  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t) (python . t) (ein . t) (dot . t) (ruby . t) (js . t) (java . t) (dot . t)))

  (add-to-list 'org-babel-default-header-args:python '((:results . "output")))
  (add-to-list 'org-babel-default-header-args:js '((:session . "js-comint") (:results . "output")))
  (add-to-list 'org-babel-default-header-args:ruby '((:results . "value"))) ;; When using :session, :results output does not work

  (setq org-src-lang-modes
    (append '(("dot" . graphviz-dot))
        (delete '("dot" . fundamental) org-src-lang-modes)))

  )


;; Org-download allows quick drag and drop functionality to embed images.
;; It also allows to take screenshot trough scrot or maim and quickly embedding them
;; in the document.
(use-package org-download
  :after org
  :config
  (setq-default org-download-image-dir "~/Pictures/org")

  :hook
  (dired-mode . org-download-enable))

(use-package org-roam
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory org-directory)
  :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))

(use-package cc-mode
  :config
  (setq c-basic-offset 4)
  (setq c-default-style (quote
             ((c-mode . "bsd")
              (c++-mode . "bsd")
              (java-mode . "bsd")
              (awk-mode . "awk")
              (other . "gnu"))))
  (c-set-offset 'case-label '+)
  (add-to-list 'auto-mode-alist '("\\.h\\'" . c-mode))
  :hook
  (c-mode . (lambda () (add-hook 'before-save-hook 'clang-format-buffer nil 'local)))
  (c++-mode . (lambda () (add-hook 'before-save-hook 'clang-format-buffer nil 'local)))
  )


(use-package highlight-numbers
  :hook
  (prog-mode . highlight-numbers-mode))

(use-package ido
  :config
  (setq ido-everywhere t)
  (setq ido-auto-merge-delay-time 3)
  (setq ido-confirm-unique-completion t)
  (setq ido-enable-flex-matching t)
  )

;; Requires
(require 'compile)
(require 'git-commit)
(require 'multiple-cursors)
(require 'winum)
(require 'saveplace)


;; Emacs customization
(defvar winparams
  '(window-parameters . ((no-other-window . t)
                         (no-delete-other-windows . t))))

(setq fit-window-to-buffer-horizontally t)
(setq window-resize-pixelwise t)

(setq
 display-buffer-alist
 `(("\\*Buffer List\\*" display-buffer-in-side-window
    (side . top) (slot . 0) (window-height . fit-window-to-buffer)
    (preserve-size . (nil . t)) ,winparams)
   ("\\*Tags List\\*" display-buffer-in-side-window
    (side . right) (slot . 0) (window-width . fit-window-to-buffer)
    (preserve-size . (t . nil)) ,winparams)
   ("\\*\\(?:help\\|grep\\|Completions\\)\\*"
    display-buffer-in-side-window
    (side . bottom) (slot . -1) (preserve-size . (nil . t))
    ,winparams)
   ("\\*\\(?:shell\\|compilation\\)\\*" display-buffer-in-side-window
    (side . bottom) (slot . 1) (preserve-size . (nil . t))
    ,winparams)))


(setenv "PROJ_WORKING_DIR" (getenv "PWD") t)

(setq-default save-place t)


(defvar original-font-size nil)

(defun adjust-font-size (delta)
  (let* ((old-size (face-attribute 'default :height))
         (new-size (max (max (max delta (- delta)) (min 400 (+ delta old-size))) 50)))

    (setq original-font-size (or original-font-size old-size))
    (set-face-attribute 'default nil :height new-size)
    (set-face-attribute 'default nil :height new-size)

    (dparo/modeline-reset)
    ;; (message "Font size set to %d (was %d)" (face-attribute 'default :height) old-size)
    ))

(defun zoom-in ()
  (interactive)
  (adjust-font-size +10))

(defun zoom-out ()
  (interactive)
  (adjust-font-size -10))

(defun zoom-reset ()
  (interactive)
  (when original-font-size
    (set-face-attribute 'default nil :height original-font-size)
    (dparo/modeline-reset)
))


(visual-line-mode 0)
(toggle-word-wrap 0)
(toggle-truncate-lines 1)

(setq initial-scratch-message "")
(setq-default initial-scratch-message "")
(setq initial-major-mode 'org-mode)
(setq-default initial-major-mode 'org-mode)

(setq truncate-lines t)
(setq word-wrap nil)
(setq-default truncate-lines t)
(setq-default word-wrap nil)


(load-theme 'gruvbox t)

(set-face-attribute 'mode-line nil :family "GeistMono Nerd Font" :height 90)
(set-face-attribute 'mode-line-inactive nil :family "GeistMono Nerd Font" :height 90)
(setq doom-modeline-height 0)
(set-face-attribute 'default nil
                    :family "GeistMono Nerd Font"
                    :height 105
                    :weight 'normal
                    :width 'normal)

(global-hl-line-mode 0)
(delete-selection-mode 1)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(fringe-mode '(8 . 8))
(global-auto-revert-mode 1)
(global-linum-mode 0)
(auto-insert-mode)
(save-place-mode 1)
(add-hook 'before-save-hook 'whitespace-cleanup)
(add-hook 'latex-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(column-number-mode 1)
(show-paren-mode 1)
(size-indication-mode 1)
(tooltip-mode 0)
(transient-mark-mode 1)
(window-divider-mode 0)
(blink-cursor-mode 0)
(savehist-mode 1)


;; Global super mode word makes identifiers such as `num_bytes` behave as a single word (underscore is part of the word)
(global-superword-mode 1)
;; Subword instead makes the behaviour consistent when using camelCase.
;; That is IF SUPER-MODE would be disabled, `numBytes` behaves as `num_bytes` and are thus considered 2 separated words
;; ENABLE THIS IF YOU DISABLE SUPERWORD MODE
;; (global-subword-mode 1)


;; Major mode for specific files
(add-to-list 'auto-mode-alist '("\\.y$" . text-mode))
(add-to-list 'auto-mode-alist '("\\.m$"  . octave-mode))


(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)
;; Highlight trailing whitespaces and tabs in red
(setq fill-column 100)
(setq whitespace-line-column 100)
(setq whitespace-style '(empty tabs indentation trailing lines-tail space-after-tab space-before-tab tab-mark trailing-mark))
(setq-default show-trailing-whitespace t)
(global-whitespace-mode 1)


(setq auto-insert-query nil)
(setq-default auto-insert-query nil)
(setq set-mark-command-repeat-pop t)
(setq window-divider-default-right-width 1)

(setq compilation-always-kill t)
(setq compilation-ask-about-save nil)
(setq compilation-scroll-output (quote first-error))
(setq compile-command "bash -c \"$BUILD\"")

(setq next-error-recenter (quote (4)))

(setq scroll-conservatively 10000)
(setq scroll-step 0)
(setq scroll-conservatively most-positive-fixnum)
(setq scroll-margin 4)

(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-scroll-amount (quote (3 ((shift) . 6) ((control)))))

(setq case-fold-search t)   ; make searches case insensitive
(setq vc-follow-symlinks t)
(setq inhibit-startup-screen t)
(setq search-whitespace-regexp ".*")
(setq isearch-lax-whitespace nil)
(setq isearch-regexp-lax-whitespace t)
(setq isearch-allow-scroll t)

;; For terminal stuff
(setq xterm-mouse-mode 1)
(xterm-mouse-mode 1)
(setq mouse-sel-mode 1)
(setq select-enable-primary nil)
(setq select-enable-clipboard t)
(setq auto-window-vscroll 1)
(setq track-mouse nil)
(setq-default track-mouse nil)
(setq delete-by-moving-to-trash t)
(setq-default delete-by-moving-to-trash t)


;; Funcs
(defun marker-is-point-p (marker)
  "Test if marker is current point."
  (and (eq (marker-buffer marker) (current-buffer))
       (= (marker-position marker) (point))))

(defun push-mark-maybe ()
  "Push mark onto `global-mark-ring' if mark head or tail is not current location."
  (if (not global-mark-ring) (error "global-mark-ring empty")
    (unless (or (marker-is-point-p (car global-mark-ring))
                (marker-is-point-p (car (reverse global-mark-ring))))
      (push-mark))))


(defun backward-global-mark ()
  "Use `pop-global-mark', pushing current point if not on ring."
  (interactive)
  (push-mark-maybe)
  (when (marker-is-point-p (car global-mark-ring))
    (call-interactively 'pop-global-mark))
  (call-interactively 'pop-global-mark))

(defun forward-global-mark ()
  "Hack `pop-global-mark' to go in reverse, pushing current point if not on ring."
  (interactive)
  (push-mark-maybe)
  (setq global-mark-ring (nreverse global-mark-ring))
  (when (marker-is-point-p (car global-mark-ring))
    (call-interactively 'pop-global-mark))
  (call-interactively 'pop-global-mark)
  (setq global-mark-ring (nreverse global-mark-ring)))


;; (load "~/.emacs.d/binds.el")
(load custom-file 'noerror)
(put 'dired-find-alternate-file 'disabled nil)
