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
