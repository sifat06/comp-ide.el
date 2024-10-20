;;; comp-ide.el --- A simple competitive programming IDE -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2021 Sidharth Arya

;; Author: Sidharth Arya <sidhartharya10@gmail.com>
;; Maintainer: Sidharth Arya <sidhartharya10@gmail.com>
;; Created: 28 May 2020
;; Version: 0.1
;; Package-Requires: ((emacs "25.1"))
;; Keywords: tools
;; URL: https://github.com/SidharthArya/comp-ide.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
;; USA.

;;; Commentary:

;; comp-ide.el attempts to be a simple and efficient competitive coding IDE.
;; The *Input* buffer is mapped to the stdin of program and *Output* buffer to stdout.
;; 

;;; Code:


(require 'delsel)
(require 'eshell)
(require 'subr-x)

(defgroup comp-ide nil
  "comp-ide.el attempts to be a simple and efficient competitive coding IDE"
  :group 'convenience
  :prefix "comp-ide-"
  :link '(url-link "https://github.com/SidharthArya/comp-ide.el"))

(defcustom comp-ide-hook '()
  "Comp IDE start hooks."
  :type 'hook)

(defcustom comp-ide-auto-execute-on-compile nil
  "Auto Execute on compile."
  :type 'bool)

(defcustom comp-ide-right-perc 30
  "Horizontal Split Percentage.  A value of 30 implies horizontal coding space would be 70%."
  :type 'integer)

(defcustom comp-ide-shell-perc 20
  "Vertical Split Percentage.  A value of 20 implies vertical coding space would be 80%."
  :type 'integer)

(defcustom comp-ide-input-perc 50
  "How much space should the *Input* buffer take in comparison to the *Output* buffer."
  :type 'integer)

(defcustom comp-ide-command-map (make-sparse-keymap)
  "Comp IDE keymap."
  :type 'keymap)

(defcustom comp-ide-comp-ide-compile-recipes nil
  "Compile Recipes for comp ide."
  :type 'list)

(defcustom comp-ide-comp-ide-execute-recipes nil
  "Execute Recipes for comp ide."
  :type 'list)

(defvar comp-ide nil)

(defvar comp-ide-extension nil)

(defvar comp-ide-file-name nil)

(defvar comp-ide-command nil)

(defvar comp-ide-temp nil)

(defvar comp-ide-code-window nil)

(defvar comp-ide-code-buffer nil)

(defvar comp-ide-output-buffer nil)

(defvar comp-ide-input-buffer nil)

(defvar comp-ide-shell-buffer nil)


(defun comp-ide-find-from-dict(list option &optional elem)
  "Allow to use list of list as a dictionary.
LIST - list to find element from
OPTION - key to match
ELEM - index value of element to return"
  (if (equal elem nil)
      (nth 1 (nth (cl-position option list :test (lambda (a b) (member a b))) list))
    (nth elem (nth (cl-position option list :test (lambda (a b) (member a b))) list))))

(defun comp-ide-insert-into-string(string identifier repl)
  "Replace an identifier in a string.
STRING - string to insert into
IDENTIFIER - string to replace
REPL - Replacing string"
  (string-join (split-string string identifier) repl))

(defun comp-ide-comp-ide-open()
  "Start the comp ide mode."
  (interactive)
  (when comp-ide-auto-execute-on-compile
    (setq compilation-finish-functions #'comp-ide-quick-execute)
    (add-to-list 'after-save-hook #'comp-ide-comp-ide-compile))
  (setq comp-ide-code-window (get-buffer-window))
  (setq comp-ide-code-buffer (current-buffer))
  (split-window-below (/ (* (- 100 comp-ide-shell-perc) (window-height)) 100))
  (other-window 1)
  (eshell)
  (comp-ide-slave-mode t)
  (set-window-dedicated-p (get-buffer-window) t)
  (setq comp-ide-shell-buffer (get-buffer-window))
  (other-window 1)
  (split-window-right (/ (* (- 100 comp-ide-right-perc) (window-width)) 100))
  (other-window 1)
  (switch-to-buffer "*Output*")
  (comp-ide-slave-mode t)
  (set-window-dedicated-p (get-buffer-window) t)
  (setq comp-ide-output-buffer (get-buffer-window))
  (split-window-vertically (/ (* (- 100 comp-ide-input-perc) (window-height)) 100))
  (other-window 1)
  (switch-to-buffer "*Input*")
  (comp-ide-slave-mode t)
  (set-window-dedicated-p (get-buffer-window) t)
  (setq comp-ide-input-buffer (get-buffer-window))
  (other-window 2)
  (setq comp-ide t)
  (run-hooks 'comp-ide-hook)
  (setq split-window-preferred-function nil))

(defun comp-ide-comp-ide-compile()
  "Compile the code."
  (interactive)
  (setq comp-ide-src (file-name-nondirectory (buffer-file-name)))
  (setq comp-ide-extension (file-name-extension comp-ide-src))
  (setq comp-ide-file-name (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))
  (setq comp-ide-command
        (comp-ide-find-from-dict comp-ide-comp-ide-compile-recipes comp-ide-extension))
  (setq comp-ide-command
        (string-join (split-string (string-join
                                    (split-string comp-ide-command "%bf") comp-ide-src) "%bo")
                     comp-ide-file-name))

  (save-excursion
    (compile comp-ide-command)))

(defun comp-ide-comp-ide-execute()
  "Execute the code."
  (interactive)
  (setq comp-ide-command (comp-ide-find-from-dict comp-ide-comp-ide-execute-recipes comp-ide-extension))
  (setq comp-ide-command (string-join (split-string (string-join (split-string comp-ide-command "%bf") (buffer-name)) "%bo") comp-ide-file-name))

  (setq comp-ide-file-name (file-name-sans-extension (buffer-file-name)))
  ;;(defvar comp-ide-file-name (nth 0 (split-string (buffer-name) "\\.")))
  (with-current-buffer (get-buffer "*Output*")
    (erase-buffer))
  (with-current-buffer (get-buffer "*Input*")
    (shell-command-on-region (point-min) (point-max) comp-ide-command))
  (with-current-buffer (get-buffer "*Shell Command Output*")
    (kill-region (point-min) (point-max))
    (kill-buffer "*Shell Command Output*"))
  (with-current-buffer (get-buffer "*Output*")
    (yank)))

(defun comp-ide-comp-ide-close()
  "Close 'comp-ide' mode."
  (interactive)
  (when comp-ide-auto-execute-on-compile
    (setq compilation-finish-functions nil)
    (setq after-save-hook (delete #'comp-ide-comp-ide-compile after-save-hook)))
  (kill-buffer "*eshell*")
  (kill-buffer "*Output*")
  ;(kill-buffer "*Input*")
  (makunbound 'ide-code-window)
  (makunbound 'ide-code-buffer)
  (makunbound 'ide-shell-buffer)
  (makunbound 'ide-output-buffer)
  (makunbound 'ide-input-buffer)
  (makunbound 'comp-ide-extension)
  (makunbound 'comp-ide-extension)
  (defvar comp-ide-file-name nil)
  (defvar comp-ide-command nil)
  (defvar comp-ide-temp nil)
  (defvar comp-ide-code-window nil)
  (defvar comp-ide-code-buffer nil)
  (defvar comp-ide-output-buffer nil)
  (defvar comp-ide-input-buffer nil)
  (defvar comp-ide-shell-buffer nil)

  (setq comp-ide nil)
  (run-hooks 'comp-ide-hooks)
  (setq split-window-preferred-function 'split-window-sensibly))

(defun comp-ide-goto-shell()
  "Goto Shell Prompt."
  (interactive)
  (select-window comp-ide-shell-buffer))

(defun comp-ide-goto-output()
  "Goto Output BUffer."
  (interactive)
  (select-window comp-ide-output-buffer))

(defun comp-ide-goto-input()
  "Goto Input Buffer."
  (interactive)
  (select-window comp-ide-input-buffer))

(defun comp-ide-goto-code()
  "Goto Code Buffer."
  (interactive)
  (select-window comp-ide-code-window)
  (switch-to-buffer comp-ide-code-buffer))

(defun comp-ide-send-to-output(string)
  "Send output of the program to buffer.
Replace the output bufferstring with STRING"
  (if (stringp string)
      (kill-append string nil))
  (with-current-buffer (get-buffer "*Output*")
    (delete-region (point-min) (point-max))
    (yank)))

(defun comp-ide-quick-execute(a b)
  "Quickly Execute the current program.
Argument A stands for process.
Argument B stands for event."
  (interactive)
  (message "%s: %s" a b)
  (comp-ide-goto-code)
  (comp-ide-comp-ide-execute))

(define-minor-mode comp-ide
  "comp-ide.el attempts to be a simple and efficient competitive coding COMP-IDE."
  :lighter " ID"
  :keymap (make-sparse-keymap)
  (if comp-ide
      (comp-ide-comp-ide-open)
    (comp-ide-comp-ide-close)))

(define-minor-mode comp-ide-slave-mode
  "slave mode for comp-ide."
  :lighter " ID"
  :keymap (make-sparse-keymap))

(provide 'comp-ide)
;;; comp-ide.el ends here
