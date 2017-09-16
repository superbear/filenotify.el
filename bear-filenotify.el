;;; bear-filenotify.el --- filenotify.el wrapper 递归监控目录 -*- lexical-binding: t -*-
;; 文件变化监控 && 自定义回调函数将文件同步至指定目录
;; filenotify.el 不会递归监控目录

;;; Commentary:
;; 更多可查看 https://www.gnu.org/software/emacs/manual/html_node/elisp/File-Notifications.html

;;; Code:

(require 'filenotify)

(defvar source-directory nil
  "被监控的文件夹")

(defvar target-directory nil
  "同步目标文件夹")

(defvar directories-to-exclude
  '("." ".." ".git" ".svn")
  "跳过的文件夹")

(defvar directories-to-watch nil
  "需要监控的文件夹列表")

(defvar show-message nil
  "是否接收 message")

(defun my-notify-callback (event)
  "File notify callback function
  从源目录（source-directory）copy 文件到指定（target-directory）目录"
  (if show-message
      (message "报告：文件发生变化%S" event))
  (let
      ((filename (nth 2 event))
       (action (nth 1 event))
       target)
    ;; .# （file lock）开头的文件不处理
    (if (not (string-prefix-p ".#" (file-name-base filename)))
        (progn
          ;; 获取当前变更文件的目标目录
          (setq target
                (replace-regexp-in-string source-directory target-directory (file-name-directory filename)))
          (cond ((eq action 'changed)
                 ;; 内容发生改变，同步至目标文件夹
                 (if (and (not (file-directory-p filename)) (file-exists-p filename))
                     (progn
                       (if (not (file-exists-p target))
                           (make-directory target t))
                       (copy-file filename target t t))))
                ((and (eq action 'created) (file-directory-p filename))
                 ;; 新建文件夹，同步加上监控
                 (file-notify-add-watch filename '(change) 'my-notify-callback))
                ;; 文件夹被删除，watch 会自动移除
                (t nil))))))


(defun get-directory-list (dir &optional recursively)
  "return directory list in dir，默认递归地获取"
  (or recursively (setq recursively t))
  (let
      ((ret-list '()))
    (progn
      (mapc
       (lambda (items)
         (if (and (equal t (nth 1 items)) (not (member (nth 0 items) directories-to-exclude)))
             (progn
               (push (concat (file-name-as-directory dir) (nth 0 items)) ret-list)
               ;; 递归获取其子文件夹中的文件夹
               (if recursively
                   (setq ret-list
                         (append (get-directory-list (concat (file-name-as-directory dir) (nth 0 items))) ret-list)))))
         ret-list)
       (directory-files-and-attributes dir))
      ret-list)))


(defun start-watch-directories ()
  "启动监控"
  (interactive)
  ;;; 校验目标文件是否存在或可读
  (cond
   ((not (file-exists-p target-directory)) (error "配置错误：目标文件夹不存在`%s'" target-directory))
   ((not (file-writable-p target-directory)) (error "配置错误：目标文件夹不可读`%s'" target-directory))
   (t (if show-message (message "配置正确"))))
  ;;; get-directory-list 会漏掉 source-directory，需自行加上
  (setq directories-to-watch
        (append (list source-directory) (get-directory-list source-directory)))
   ;;; 遍历指定文件夹 list，并加上监控
  (while directories-to-watch
    (progn
      (file-notify-add-watch
       (car directories-to-watch) '(change) 'my-notify-callback))
    (setq directories-to-watch (cdr directories-to-watch))))


(defun get-all-watched-directories ()
  "查看监控中的文件夹"
  (interactive)
  (print "被监控的目录列表：")
  (maphash (lambda (key value)
             (print (nth 0 value))) file-notify-descriptors)
  (switch-to-buffer "*Messages*"))


(defun clear-all-file-notify-descriptors ()
  "手动移除所有 descriptor"
  (interactive)
  (maphash (lambda (key value)
             (file-notify--rm-descriptor key)) file-notify-descriptors))


(provide 'bear-filenotify)
;;; bear-filenotify.el ends here
