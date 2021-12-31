;;; My EMACS config

;;; Variables
(defvar buffer-width 80
  "The width of the buffer in characters.")
(defvar mouse-scroll-amount 1
  "The number of lines moved by scrolling once")

;;; Minimal UI
(setq inhibit-startup-message t
      frame-resize-pixelwise  t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; Theme
(set-face-attribute 'default nil :font "Hack-11")
(add-to-list 'default-frame-alist '(font . "Hack-11"))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold nil
        doom-themes-enable-italic t)
  (load-theme 'doom-tokyo-night t)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom")
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom ((doom-modeline-height 30))) ; For best appearance, height should exceed font height

;;; Input
(setq mouse-wheel-progressive-speed nil)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Use ESC to exit

;;; Smooooooooth
(setq scroll-step 1)
(setq mouse-wheel-scroll-amount '(mouse-scroll-amount))

;;; Icons
(use-package all-the-icons
  :if (display-graphic-p))

;;; Completion
;; (use-package swiper
;;   :bind (("C-s" . swiper)))

(use-package ivy
  :diminish
  :bind (:map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel   
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

;; Dedicated backup directory
(setq backup-directory-alist
  `(("." . ,(concat user-emacs-directory "backups/"))))
(setq auto-save-file-name-transforms
  `((".*" "~/.emacs.d/saves/" t)))

;;; Line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
   		term-mode-hook
        	eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;; Which Key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;;; Keep customize seperate and temporary
(setq custom-file (make-temp-file "emacs-custom.el"))

;;; Flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;; LSP Setup
(use-package lsp-mode
  :ensure t
  :bind-keymap
  ("C-c l" . lsp-command-map)
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-signature-auto-activate nil))

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-doc-enable nil))

;;; Languages
(use-package csharp-mode
  :mode "\\.cs\\'"
  :hook (csharp-mode . lsp))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . lsp))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . lsp))

;; C
(setq-default c-basic-offset 4
              indent-tabs-mode nil
              c-default-style "linux"
              tab-width 4)

;;; Code Completion
(use-package company
  :ensure
  :custom
  (company-idle-delay 0.1)) ;; Wait before revealing popup

;;; Performance
;; Necessary due to lsp servers using more resources than base emacs

(setq gc-cons-threshold 100000000
      read-process-output-max (* 1024 1024))

;; Don't show nativecomp warning buffer
(setq native-comp-async-report-warnings-errors nil)

;; TRAMP mode
(setq tramp-default-method "ssh")

;; Enter text in window
(defun my-resize-margins ()
  (let ((margin-size (/ (- (frame-width) buffer-width) 2)))
    (set-window-margins nil margin-size margin-size)))

(add-hook 'window-configuration-change-hook #'my-resize-margins)
(my-resize-margins)
