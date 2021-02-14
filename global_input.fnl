(fn [program]
  (tset program :global-input-handlers
        [{:pattern "C-q"
          :short-description "Quit program."
          :func (fn [program]
                  "Stop program."
                  (tset program :continue false))}

         {:pattern "C-r"
          :short-description "Reload dynamic modules."
          :func (fn [program]
                  "Reload dynamic modules."
                  (program.reload))}

         {:pattern "C-p"
          :short-description "Inform of mouse (cell) position."
          :func (fn [program]
                  (local terminal program.terminal)
                  (local mx (terminal.state terminal.TK_MOUSE_X))
                  (local my (terminal.state terminal.TK_MOUSE_Y))
                  (program.log :dbg "Mouse coords: %s:%s" mx my))}
         ])
  )
