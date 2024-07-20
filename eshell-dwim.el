;;; eshell-dwim.el --- Do open eshell smartly -*- lexical-binding: t -*-

;;; Commentary:
;; Do open eshell smartly.  M-x eshell-dwim or M-x eshell-dwim-project.

;; Author: VHQR <zq_cmd@163.com>
;; Version: 1.0.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: eshell, convenience
;; URL: https://github.com/vhqr0/eshell-dwim

;;; Code:

(require 'cl-lib)
(require 'project)
(require 'eshell)
(require 'esh-mode)
(require 'em-dirs)

(defun eshell-dwim (&optional arg)
  "Do open eshell smartly.

without universal ARG, open in split window.
With one universal ARG, open other window.
With two or more universal ARG, open in current window."
  (interactive "P")
  (let* ((window-buffer-list (mapcar #'window-buffer (window-list)))
         (buffer (cl-find-if
                  (lambda (buffer)
                    (and (eq (with-current-buffer buffer major-mode) 'eshell-mode)
                         (string-prefix-p eshell-buffer-name (buffer-name buffer))
                         (not (get-buffer-process buffer))
                         (not (member buffer window-buffer-list))))
                  (buffer-list))))
    (if buffer
        (let ((dir default-directory))
          (with-current-buffer buffer
            (eshell/cd dir)
            (eshell-reset)))
      (setq buffer (generate-new-buffer eshell-buffer-name))
      (with-current-buffer buffer
        (eshell-mode)))
    (cond ((> (prefix-numeric-value arg) 4)
           (switch-to-buffer buffer))
          (arg
           (switch-to-buffer-other-window buffer))
          (t
           (let ((parent (window-parent (selected-window))))
             (cond ((window-left-child parent)
                    (select-window (split-window-vertically))
                    (switch-to-buffer buffer))
                   ((window-top-child parent)
                    (select-window (split-window-horizontally))
                    (switch-to-buffer buffer))
                   (t
                    (switch-to-buffer-other-window buffer))))))))

(defun eshell-dwim-project (&optional arg)
  "Do open a project-wide eshell smartly.
ARG see `eshell-dwim'."
  (interactive "P")
  (let* ((project (project-current))
         (default-directory (if project (project-root project) default-directory))
         (eshell-buffer-name (project-prefixed-buffer-name "eshell")))
    (eshell-dwim arg)))

(provide 'eshell-dwim)
;;; eshell-dwim.el ends here
