# filenotify.el
emacs filenotify

## 自带的 filenotify 存在以下问题
1. 不会递归监控文件夹
2. 不会自动加上新建目录的监控

# How to Use
```emacs lisp
(require 'bear-filenotify)

(setq source-directory "/path/to/dira")

(setq target-directory "/path/to/dirb")

;; 开始监控
M-x start-watch-directories
;; 查看监控的目录
M-x get-all-watched-directories
```
# 其他
1. 文件夹下会产生类似 #autosave#、backup~ 的备份文件，这些文件的变化也会被监控。可以选择关闭，也可以集中保存
```emacs lisp
;; 备份文件集中保存                                                                                                           
(custom-set-variables                                                                                                          
 '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))                                                      
 '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))                                                                  
(make-directory "~/.emacs.d/autosaves/" t)
```
