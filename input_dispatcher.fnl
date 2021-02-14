(fn input-handler [program]
  (local terminal program.terminal)


  ;; blocking read ...
    (local input (terminal.read))

  (fn table? [v]
    "Test wheter `v' is a table value."
    (= "table" (type v)))

  (fn char-at [pos str]
    "Get the character at position `pos' in string `str'."
    (string.sub str pos pos))

  (fn parse-pattern [pattern]
    "Pretty hacky stuff going on here, but works for now."
    (local result {})
    (when (= "!" (char-at 1 pattern))
      ;; this is a literal TK_* key
      (let [tk-key (string.sub pattern 2)]
        (tset result :tk-key tk-key)))
    (when (and (= "C" (char-at 1 pattern))
               (= "-" (char-at 2 pattern)))
      (tset result :control true)
      (let [kbkey (char-at 3 pattern)]
        (tset result :tk-key (.. "TK_" (string.upper kbkey)))))

    result)

  (fn is-applicable [pattern inp]
    (var result false)
    (if (table? pattern) ;; supports multiple bindings.
        (each [_ inner-pattern (ipairs pattern)]
          (when (is-applicable inner-pattern inp)
            (set result true)))

        ;; else =>
        (let [cfg (parse-pattern pattern)
              correct-tk? (= inp (. terminal cfg.tk-key))
              correct-ctrl? (= (not cfg.control)
                               (not (terminal.check terminal.TK_CONTROL)))]
          (set result (and correct-tk? correct-ctrl?)))
        )

    result)

  (fn try-find-handler []
    (each [i spec (ipairs program.global-input-handlers)]
      (when (is-applicable spec.pattern input)
        (lua "return spec.func"))))

  (local found-handler (try-find-handler))

  (when found-handler
    (found-handler program))

  ;; show the mouse avatar, if it moved and is enabled
  (when program.use-mouse
    (tset program :show-mouse-cursor false)
    (when (= input terminal.TK_MOUSE_MOVE)
      (tset program :show-mouse-cursor true)))

  ;; check if we should stop the program
  (when (= input terminal.TK_CLOSE)
    (tset program :continue false))

  ;; return all data needed by the main loop.
  {:read input})
