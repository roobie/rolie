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

         {:pattern "C-d"
          :short-description "Eval some code."
          :func (fn [program]
                  ;; We can get text input from user - TBD how to run as code,
                  ;; with correct environment/scope.
                  (local layout program.layout)
                  (local box layout.boxes.botl) ; use bottom left box
                  (local terminal program.terminal)
                  (let [prompt "> "
                        (len buf) (terminal.read_str box.x1 box.y1 prompt)
                        input (string.sub buf (+ 1 (length prompt)))
                        result-fn (load (.. "return ({" input "})"))
                        (ok result) (pcall (setfenv result-fn {:program program}))]
                    (if (not ok)
                        (program.log :wrn "Error: %s" result)
                        (program.log :inf "%s" (program.view result))
                        )
                    ))}

         {:pattern "C-p"
          :short-description "Inform of mouse (cell) position."
          :func (fn [program]
                  (local terminal program.terminal)
                  (local mx (terminal.state terminal.TK_MOUSE_X))
                  (local my (terminal.state terminal.TK_MOUSE_Y))
                  (program.log :dbg "Mouse coords: %s:%s" mx my))}
         ])
  )
