
;; For debug introspection.
(local view (require :fennel.fennelview))

(local terminal (require :BearLibTerminal))

(local program {:continue true
                :view view
                :log-levels {:dbg 1
                             :vrb 2
                             :inf 3
                             :wrn 4
                             :err 5
                             :fat 6}
                :log-level :dbg
                :log-history {}
                :terminal terminal
                :colors {}})

(fn program.pp [value]
  "Pretty print a value to stdout."
  (print (view value)))

(fn program.log [level fmt ...]
  (local levels (. program :log-levels))
  (when (>= (. levels level) (. levels program.log-level))
    (local entry (.. (os.time) "|" level "> " (string.format fmt ...)))
    (print entry)
    (let [entries (. program :log-history)]
      (table.insert entries entry))))

(fn re-require [modname]
  "Removes the loaded module and then `require's it anew."
  (local loaded package.loaded)
  (tset loaded modname nil)
  (require modname))

(fn reload [modname]
  "Reload the module named `modname'."
  (program.log :dbg "Reloading: %s" modname)
  (tset program modname (re-require modname)))

(fn main-loop []
  (while program.continue
    (program.renderer program)
    (program.processor program)
    (let [input (program.input_handler program)]
      (when (and (terminal.check terminal.TK_CONTROL)
                 (= input.read terminal.TK_R))
        (reload :renderer)
        (reload :processor)
        (reload :input_handler)
        (program.log :inf "System reloaded.")))
    )
  )


(fn setopt [k v]
  (terminal.set (string.format "%s=%s;" k v)))

(fn load-colors []
  (local colors (. program :colors))
  (tset colors :white (terminal.color_from_name "white"))
  (tset colors :black (terminal.color_from_name "black"))

  colors)

(fn program.run []
  (tset program :renderer (require :renderer))
  (tset program :processor (require :processor))
  (tset program :input_handler (require :input_handler))

  (terminal.open)

  (setopt :window.title :Rolie-v1.0.0)
  (setopt :window.size :120x45)
  (setopt :window.resizeable :true)

  (when program.use-mouse
    (setopt :input.mouse-cursor :false)
    (setopt :input.filter "[keyboard, mouse+]")
    (terminal.composition terminal.TK_ON)
    )

  (local colors (load-colors))

  ;; explicitly set defaults.
  (terminal.color colors.white)
  (terminal.bkcolor colors.black)

  (main-loop)

  (terminal.close))

program
