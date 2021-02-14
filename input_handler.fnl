(fn input-handler [program]
  (local terminal program.terminal)

  (local input (terminal.read))

  (tset program :show-cursor false)
  (when (= input terminal.TK_MOUSE_MOVE)
    (tset program :show-cursor true))
  (let [close (= input terminal.TK_CLOSE)
        quit (and (terminal.check terminal.TK_CONTROL)
                  (= input terminal.TK_Q))]
    (tset program :continue (and (not close)
                                 (not quit))))
  (when (and (terminal.check terminal.TK_CONTROL)
             (= input terminal.TK_P))
    (local mx (terminal.state terminal.TK_MOUSE_X))
    (local my (terminal.state terminal.TK_MOUSE_Y))
    (program.log :dbg "Mouse coords: %s:%s" mx my))

  ;; (program.log :dbg "Input: %s" input)

  ;; return all data needed by the main loop.
  {:read input})
