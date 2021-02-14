
;; For debug introspection.
(local view (require :fennel.fennelview))

(local terminal (require :BearLibTerminal))

(local program {:continue true
                :terminal terminal})

(fn program.pp [value]
  "Pretty print a value to stdout."
  (print (view value)))

(fn program.log [level fmt ...]
  (print (.. "[" (os.time) "|" level "]: " (string.format fmt ...))))

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
    (let [input (program.input-handler program)]
      (when (and (terminal.check terminal.TK_CONTROL)
                 (= input.read terminal.TK_R))
        (reload :renderer)
        (reload :processor)
        (reload :input_handler)
        (program.log :dbg "Reloaded.")))
    )
  )

(fn program.run []
  (tset program :renderer (require :renderer))
  (tset program :processor (require :processor))
  (tset program :input-handler (require :input_handler))

  (terminal.open)

  (main-loop)

  (terminal.close))

program
