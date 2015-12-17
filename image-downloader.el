;;; image-downloader.el --- sample program of binary downloading with url.el -*- lexical-binding: t; -*-

;; Copyright (C) 2015 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-image-downloader
;; Version: 0.01
;; Package-Requires: ((emacs "24.3"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(eval-when-compile
  (defvar url-http-end-of-headers)
  (defvar url-http-response-status))

(require 'url)
(require 'image-file)

(defun image-download-callback (url _status)
  (goto-char url-http-end-of-headers)
  (while (re-search-forward "src=\"\\([^\"]+\\)\"" nil t)
    (let ((src (match-string-no-properties 1)))
      (unless (string-prefix-p "http" src)
        (setq src (concat url src)))
      (when (member (file-name-extension src) image-file-name-extensions)
        (message "Download %s" src)
        (url-retrieve
         src
         (lambda (_status)
           (if (/= url-http-response-status 200)
               (message "Failed download: %s" url)
             (goto-char (point-min))
             (when (re-search-forward "\r?\n\r?\n" nil t)
               (let ((image (buffer-substring (point) (point-max)))
                     (name (file-name-nondirectory src)))
                 (message "Save as %s" name)
                 (with-temp-file name
                   (let ((coding-system-for-write 'binary))
                     (insert image))))))))))))

;;;###autoload
(defun image-download (url)
  (interactive
   (list (read-string "URL: ")))
  (url-retrieve url (lambda (status)
                      (image-download-callback url status)) nil t))

(provide 'image-downloader)

;;; image-downloader.el ends here
