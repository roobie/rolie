(fn input-handler [program]
  (local terminal program.terminal)

  (local input (terminal.read))
  (let [close (= input terminal.TK_CLOSE)
        quit (and (terminal.check terminal.TK_CONTROL)
                  (= input terminal.TK_Q))]
    (tset program :continue (and (not close)
                                 (not quit))))

  ;; return data
  {:read input})
