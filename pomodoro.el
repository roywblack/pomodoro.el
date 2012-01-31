;;; pomodoro.el --- Pomodoro Technique for emacs

;; Author: Ivan Kanis
;; Copyright (C) 2011 Ivan Kanis
;; Copyright (C) 2011-2012 Victor Deryagin <vderyagin@gmail.com>
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

;;; Commentary:

;;
;; Information on installation and usage can be found in the README.md file
;;

;;; Code:

(require 'notifications)

(defvar pomodoro-work-time 25
  "Time in minutes of work")

(defvar pomodoro-short-break 5
  "Time in minutes of short break")

(defvar pomodoro-long-break 15
  "Time in minutes of long break")

(defvar pomodoro-set-number 4
  "Number of sets until a long break")

(defvar pomodoro-icon notifications-application-icon
  "Icon used for notification")

(defvar pomodoro-display-string "")
(defvar pomodoro-minute)
(defvar pomodoro-set)
(defvar pomodoro-timer nil)
(defvar pomodoro-state 'work)

;;;###autoload
(defun pomodoro ()
  "Start pomodoro, also rewind pomodoro to first set."
  (interactive)
  (if (pomodoro-running-p)
      (when (y-or-n-p "Pomodoro is alredy running. Restart it?")
        (cancel-timer pomodoro-timer)
        (pomodoro))
      (setq pomodoro-paused nil)
      (or global-mode-string (setq global-mode-string '("")))
      (or (memq 'pomodoro-display-string global-mode-string)
          (setq global-mode-string
                (append global-mode-string '(pomodoro-display-string))))
      (setq pomodoro-minute pomodoro-work-time
            pomodoro-set 1
            pomodoro-state 'work
            pomodoro-timer (run-at-time t 60 'pomodoro-timer))
      (pomodoro-update-modeline)
      (pomodoro-status)))

(defun pomodoro-rewind ()
  "Rewind pomodoro, keep current set"
  (interactive)
  (if (pomodoro-running-p)
      (progn
        (setq pomodoro-minute pomodoro-work-time
              pomodoro-state 'work)
        (pomodoro-update-modeline)
        (pomodoro-status))
      (when (y-or-n-p "Pomodoro isn't running. Start it?")
        (pomodoro))))

(defun pomodoro-skip-forward ()
  "Skip forward to the start of the next step"
  (interactive)
  (if (< pomodoro-set pomodoro-set-number)
      (setq pomodoro-set (1+ pomodoro-set))
      (setq pomodoro-set 1))
  (setq pomodoro-minute pomodoro-work-time
        pomodoro-state 'work)
  (pomodoro-update-modeline)
  (pomodoro-status))

(defun pomodoro-stop ()
  "Stop pomodoro."
  (interactive)
  (if (pomodoro-running-p)
      (progn
        (cancel-timer pomodoro-timer)
        (delq 'pomodoro-display-string global-mode-string)
        (pomodoro-status))
      (when (y-or-n-p "Pomodoro isn't running. Start it?")
        (pomodoro))))

(defun pomodoro-toggle-pause ()
  "Pauses pomodoro timer"
  (interactive)
  (if (pomodoro-running-p)
      (progn
        (setq pomodoro-paused (not pomodoro-paused))
        (pomodoro-update-modeline)
        (pomodoro-status))
      (when (y-or-n-p "Pomodoro isn't running. Start it?")
        (pomodoro))))

(defun pomodoro-status ()
  "Display a status message via libnotify"
  (interactive)
  (let ((notification-body
         (if (pomodoro-running-p)
             (concat (format "%d set\n" pomodoro-set)
                     (format "%d minute(s) left" pomodoro-minute))
             "")))
    (notifications-notify
     :title    (pomodoro-current-state)
     :body     notification-body
     :app-icon pomodoro-icon)))

(defun pomodoro-current-state ()
  "Current pomodoro state as string"
  (catch 'current-state
    (let ((state
           (cond
             ((not (pomodoro-running-p))
              (throw 'current-state "Not running"))
             ((eq pomodoro-state 'work)
              "Work")
             ((eq pomodoro-state 'short-break)
              "Short break")
             ((eq pomodoro-state 'long-break )
              "Long break"))))
      (throw 'current-state
        (if pomodoro-paused
            (format "%s (paused)" state)
            state)))))

(defun pomodoro-timer ()
  "Function called every minute.
It takes care of updating the modeline"
  (unless pomodoro-paused
    (setq pomodoro-minute (1- pomodoro-minute))
    (when (<= pomodoro-minute 0)
      (cond
        ((eq pomodoro-state 'long-break)
         (setq pomodoro-state 'work
               pomodoro-set 1
               pomodoro-minute pomodoro-work-time))
        ((eq pomodoro-state 'short-break)
         (setq pomodoro-state 'work
               pomodoro-minute pomodoro-work-time
               pomodoro-set (1+ pomodoro-set)))
        ((eq pomodoro-state 'work)
         (if (>= pomodoro-set pomodoro-set-number)
             (setq pomodoro-minute pomodoro-long-break
                   pomodoro-state 'long-break)
             (setq pomodoro-minute pomodoro-short-break
                   pomodoro-state 'short-break))))
      (pomodoro-status))
    (pomodoro-update-modeline)))

(defun pomodoro-update-modeline ()
  "Update the modeline."
  (setq pomodoro-display-string
        (cond
          ((eq pomodoro-state 'work)
           (format "W%d-%d" pomodoro-set pomodoro-minute))
          ((eq pomodoro-state 'short-break)
           (format "B%d-%d" pomodoro-set pomodoro-minute))
          (t
           (format "LB-%d" pomodoro-minute))))
  (when pomodoro-paused
    (setq pomodoro-display-string
          (format "%s (paused)" pomodoro-display-string)))
  (force-mode-line-update))

(defun pomodoro-running-p ()
  "Check if pomodoro is currently running"
  (memq pomodoro-timer timer-list))

(provide 'pomodoro)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; pomodoro.el ends here
