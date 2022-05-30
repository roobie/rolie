
;; For debug introspection.
(local view (require :fennel.fennelview))


(local terminal (require :BearLibTerminal))


(local program {;; whether to continue execution.
                :continue true

                :loop-count 0

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

                :step 1
                :process-count 0
                :step-once true

                :entities {}
                :entity-manager {} ; to be set by processor
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
    (local entry (string.format
                  "%s|%s|%08x> %s"
                  level program.process-count program.log-counter msg))
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
  (let [mod (re-require modname)]
    (tset program modname mod)
    mod))


(fn main-loop []
  (while program.continue
    (program.processor program)
    (tset program :step (math.max 0 (+ -1 program.step)))
    (program.renderer program)
    (let [input (program.input_dispatcher program)]
      (when (= input.read terminal.TK_RESIZED)
        (local tw (terminal.state terminal.TK_WIDTH))
        (local th (terminal.state terminal.TK_HEIGHT))
        (local ok-tw (math.max tw program.minimal-dimensions.width))
        (local ok-th (math.max th program.minimal-dimensions.height))
        (terminal.set (string.format "window.size=%dx%d" ok-tw ok-th)))
      )
    (tset program :loop-count (+ 1 program.loop-count)))

  (program.log :inf "Exiting program. Bye."))


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

  (local global-input (reload :global_input))
  (global-input program)

  (reload :input_dispatcher)

  (program.log :inf "System reloaded."))


(fn program.run []
  (tset program :renderer (require :renderer))

  (tset program :processor (require :processor))

  (local global-input (require :global_input))
  (global-input program)

  (tset program :input_dispatcher (require :input_dispatcher))

  (terminal.open)

  (setopt :window.title :Rolie-v1.0.0)
  (setopt :window.size :120x45)
  (setopt :window.resizeable :true)

  (setopt :palette.octarine "#50FF25")

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
