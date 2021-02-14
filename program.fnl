
;; For debug introspection.
(local view (require :fennel.fennelview))


(local terminal (require :BearLibTerminal))


(local program {;; whether to continue execution.
                :continue true

                ;; stringifier of tables etc.
                :view view

                ;; logging
                :log-levels {:dbg 1
                             :vrb 2
                             :inf 3
                             :wrn 4
                             :err 5
                             :fat 6}
                :log-level :dbg
                :log-counter 0
                :log-max-entries 0xff
                :log-history {}

                ;; the `terminal' library
                :terminal terminal

                ;; These are the minimal dimensions allowed
                ;; for the terminal window.
                :minimal-dimensions {:width 80
                                     :height 25}

                ;; currently active input handlers
                :global-input-handlers {}
                :local-input-handlers {}

                ;; Lookup for colors.
                :colors {}

                })


(fn program.pp [value]
  "Pretty print a value to stdout."
  (print (view value)))


(fn program.log [level fmt ...]
  (local levels (. program :log-levels))
  (when (>= (. levels level) (. levels program.log-level))
    ;; truncate too long history, keeping the most recent 50% entries
    (when (>= (length program.log-history) program.log-max-entries)
      (let [len (length program.log-history)
            old-hist program.log-history
            new-hist {}]
        (for [i (math.floor (/ len 2)) len]
          (table.insert new-hist (. old-hist i)))
        (tset program :log-history new-hist)
        (program.log :dbg "Log truncated: %x -> %x" (length old-hist) (length new-hist))))
    (tset program :log-counter (+ 1 program.log-counter))
    (local msg (string.format fmt ...))
    (local entry (string.format "%s|%08x> %s" level program.log-counter msg))
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
      (when (= input.read terminal.TK_RESIZED)
        (local tw (terminal.state terminal.TK_WIDTH))
        (local th (terminal.state terminal.TK_HEIGHT))
        (local adjusted-tw (math.max tw program.minimal-dimensions.width))
        (local adjusted-th (math.max th program.minimal-dimensions.height))
        (terminal.set (string.format "window.size=%dx%d" adjusted-tw adjusted-th)))
      )
    )
  )


(fn setopt [k v]
  (terminal.set (string.format "%s=%s;" k v)))


(fn load-colors []
  (local colors (. program :colors))
  (tset colors :white (terminal.color_from_name "white"))
  (tset colors :black (terminal.color_from_name "black"))

  colors)


(fn program.reload []
  (reload :renderer)
  (reload :processor)
  (reload :input_handler)
  (program.log :inf "System reloaded."))


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
