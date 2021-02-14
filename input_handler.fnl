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
  (when (= input terminal.TK_A)
    (program.log :dbg "Key pressed: %s" "A"))

  ;; (program.log :dbg "Input: %s" input)

  ;; return all data needed by the main loop.
  {:read input})
