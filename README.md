# pomodoro.el #

The technique is described in http://www.pomodorotechnique.com

[Original code](http://kanis.fr/hg/lisp/ivan/pomodoro.el) written by Ivan Kanis. This fork uses libnotify for notifications instead of popup emacs buffer.

## Usage ##

to start the pomodoro you issue `M-x pomodoro`.

In the modeline you will see indicator `W1-25`. This means that you are working on set 1 and that you have 25 minutes remaining. You'll also get notification:

![](http://i55.tinypic.com/dws2f.jpg)

The counter will decrease each minutes. When it reaches 0 you will get notification that it's time to take a break:

![](http://i54.tinypic.com/2hi2wiw.jpg)

The modeline will display `B1-5`, that is you have a break of 5 minutes. When the count reaches 0 you will get another notification to get back to work and the set number will increase:

![](http://i55.tinypic.com/359bde1.jpg)

At the end of the 4th set you will get a long break:

![](http://i53.tinypic.com/348k74x.jpg)

The modeline will display `LB` instead of `B`.

When you don't need the pomodoro anymore you do `M-x pomodoro-stop`. Pomodoro will finish it's work:

![](http://i54.tinypic.com/2hoep2v.jpg)

If you got interrupted and you want to rewind the pomodoro on the current set just do `M-x pomodoro-rewind`

Calling `M-x pomodoro` again will reset it to the first working set

Calling `M-x pomodoro-toggle-pause` will pause/unpause pomodoro.

Calling `M-x pomodoro-status` will show you notification about current pomodoro state, time left and set number:

![](http://i51.tinypic.com/4ut0d0.jpg)

## Installation ##

For status change notifications working you need:

* Libnotify installed
* D-Bus session running
* **notifications.el** (included in GNU Emacs 24, which is not yet released, if you using older version - take notifications.el [here](http://bazaar.launchpad.net/~vcs-imports/emacs/trunk/annotate/head%3A/lisp/notifications.el))

To activate pomodoro.el simply put it in your load path. For example if you put the file is in the directory ~/tmp you need to do the following :

    (add-to-list 'load-path "~/tmp")
    (require 'pomodoro)

Alternatively, if you use [el-get](https://github.com/dimitri/el-get) (highly recommended), use this recipe:

    (:name pomodoro
     :type git
     :url "https://github.com/vderyagin/pomodoro.el.git"
     :post-init (lambda ()
                  (setq pomodoro-icon (expand-file-name "pomodoro/pomodoro_technique.png" el-get-dir))))

## Customizing ##

You can customize this mode with the following variables:

`pomodoro-work-time` - number of minutes of working

`pomodoro-short-break` - number of minutes of a short break

`pomodoro-long-break` - number of minutes of a long break

`pomodoro-set-number` - number of sets until a long break

`pomodoro-icon` -  icon for use in notifications
