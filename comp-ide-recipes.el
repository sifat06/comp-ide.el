;;; comp-ide-recipes.el --- Default recipes for comp-ide

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

;; Default Recipes for comp ide
;;; Code:


(defgroup comp-ide nil
  "comp-ide.el attempts to be a simple and efficient competitive coding IDE"
  :group 'convenience
  :prefix "comp-ide-"
  :link '(url-link "https://github.com/SidharthArya/comp-ide.el"))

(defcustom comp-ide-comp-ide-compile-recipes nil
  "Compile Recipes for comp ide."
  :type 'list
  :group 'comp-ide)

(defcustom comp-ide-comp-ide-execute-recipes nil
  "Execute Recipes for comp ide."
  :type 'list
  :group 'comp-ide)

(setq comp-ide-comp-ide-compile-recipes '(("c" "gcc %bf -o %bo")
                                     ("cpp" "g++ %bf -o %bo")
                                     ("java" "javac %bf")
                                     ("hs" "ghc %bf")
                                     ("go" "go build %bf")
                                     ("rs" "rustc %bf")))

(setq comp-ide-comp-ide-execute-recipes '(("c" "%bd")
                                     ("cpp" "%bd")
                                     ("py" "python ./%bf")
                                     ("java" "java %bo")
                                     ("hs" "./%bo")
                                     ("js" "nodejs %bf")
                                     ("go" "./%bo")
                                     ("php" "php %bf")
                                     ("rb" "ruby %bf")
                                     ("rs" "./%bo")))

(provide 'comp-ide-recipes)
;;; comp-ide-recipes.el ends here
