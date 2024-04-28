;;;;;;;;;; Package Management ;;;;;;;;;;

(require 'package) ; load the package manager
(setq package-check-signature nil) ; override signature errors
;; add package archives to package manager
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize) ; exactly what it sounds like 
;; pull archvies and prevent warning messages only on very first startup
(unless package-archive-contents
  (progn
    (setq warning-minimum-level :emergency) 
    (package-refresh-contents)))
;; install use-package if it doesn't exist yet
(unless (package-installed-p 'use-package) 
  (package-install 'use-package))          
(require 'use-package) ; load use-package
;; Make use-package uses package.el, prevents having to use :ensure t on everything
(setq use-package-always-ensure t) 


;;;;;;;;;; Keybinds ;;;;;;;;;;

(use-package evil 
  :init
  (setq evil-want-keybinding nil) ; needed when using with evil collection
  :config
  (evil-mode 1))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(magit term help dashboard dired ibuffer tetris))
  (evil-collection-init))
(use-package general
  :config
  ;; By default, to escape the mini-buffer, you need to hit ESC 3 times, this
  ;; bind changes that, so it only takes one.
  (general-define-key
    :keymaps 'minibuffer-local-map
    "<escape>" #'keyboard-escape-quit)

  ;; Let an active leader key for normal, visual, and emacs states
  (general-create-definer leader
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode
  (leader
    "f" '(:ignore t :wk "Find file")
    "f f" '(find-file :wk "Find file directly"))
  (leader
    "b" '(:ignore t :wk "Buffer")
    "b f" '(switch-to-buffer* :wk "Find a buffer, or create a new one")
    "b k" '(kill-this-buffer :wk "Kill the current buffer")
    "b r" '(revert-buffer :wk "Reload the current buffer"))
  (leader
    "c" '(:ignore t :wk "Comment")
    "c r" '(comment-region :wk "Comment selection")
    "c l" '(comment-line :wk "Comment line"))
  (leader
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Help function")
    "h v" '(describe-variable :wk "Help variable")
    "h m" '(describe-mode :wk "Help mode")
    "h c" '(describe-char :wk "Help character")
    "h k" '(describe-key :wk "Help key/keybind")))
(use-package key-chord
  :init
  (key-chord-mode 1)
  :config
  (setq key-chord-two-keys-delay 1
        key-chord-one-key-delay 1.2
        key-chord-safety-interval-forward 0.1
        key-chord-safety-interval-backward 1)
  (key-chord-define evil-insert-state-map  "jj" 'evil-normal-state))
(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
		which-key-sort-order #'which-key-key-order-alpha
		which-key-sort-uppercase-first nil
		which-key-add-column-padding 1
		which-key-max-display-columns nil
		which-key-min-display-lines 6
		which-key-side-window-slot -10
		which-key-side-window-max-height 0.25
		which-key-idle-delay 0.8
		which-key-max-description-length 25
		which-key-allow-imprecise-window-fit t
		which-key-separator " → " ))


;;;;;;;;;; Functionality ;;;;;;;;;;

;; Minibuffer
(use-package vertico
  :general
  ;; you probably want this, lets backspace delete and entire directory completion, instead of
  ;; one char at a time.
  (:keymaps 'vertico-map
    "<backspace>" #'vertico-directory-delete-char
    "DEL" #'vertico-directory-delete-char)
  :init
  (vertico-mode))
(use-package marginalia
  :init
  (marginalia-mode))
(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Completion
(use-package corfu
  :config
  (setq corfu-popupinfo-delay 0
        corfu-auto t
        corfu-cycle t
        corfu-preselect 'prompt
        corfu-auto-delay 0.2
        corfu-auto-prefix 2)
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  :init
  (corfu-popupinfo-mode)
  (global-corfu-mode)
  (corfu-history-mode))
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;;;;;;;;;; Style ;;;;;;;;;;

;; Best theme dont @ me
(use-package catppuccin-theme
  :config
  (setq catppuccin-highlight-matches t)
  (load-theme 'catppuccin t))
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))
;; Better highlighting in dired buffers
(use-package diredfl
  :config
  (diredfl-global-mode))

;;;;;;;;;; Preferences ;;;;;;;;;;

;; set font size to 12 point
(set-face-attribute 'default nil :height 120)
;; disable menus
(menu-bar-mode -1)
;; disable toolbar
(tool-bar-mode -1)
;; disable scrollbar
(scroll-bar-mode -1)
;; automatically close pairs like (), [] and {}
(electric-pair-mode 1)
;; highlight the current line
(global-hl-line-mode)
;; automatically indent
(electric-indent-mode t)
;; display line numbers
(global-display-line-numbers-mode 1)
;; truncate lines, nowrap
(setq-default truncate-lines t)
;; stop emacs from inserting impertive configs into init.el
;; by dumping them into a custom.el file that will never be loaded
(setq custom-file (concat user-emacs-directory "/custom.el") 
      make-backup-files nil ; stop creating backup ~ files
      auto-save-default nil ; stop creating autosave # files
      create-lockfiles nil  ; stop creating lock .# files
      blink-cursor-mode nil ; exactly what is sounds like
      use-short-answers t   ; lets you type y,n instead of yes,no when prompted
      use-dialog-box nil    ; disable gui menu pop-ups
      display-line-numbers-type 'relative ; enable relative line numbers
      password-cache-expiry nil) ; prevents tramp passwords from expiring
;; Automatically refresh dired buffer when a change on disk is made
(add-hook 'dired-mode-hook 'auto-revert-mode)
