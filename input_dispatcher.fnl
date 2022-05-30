
(fn table? [v]
  "Test wheter `v' is a table value."
  (= "table" (type v)))

(fn char-at [pos str]
  "Get the character at position `pos' in string `str'."
  (string.sub str pos pos))

(fn input-handler [program]
  (local terminal program.terminal)

  (var input nil)

  (local do-blocking-read
         (or (< 0 (terminal.peek))
             (and program.step-once (< program.step 1))))
  (if do-blocking-read
      ;; blocking read ...
      (set input (terminal.read))
      (if (< 0 (terminal.peek))
          (do
            (print "t" (terminal.peek))
            (set input (terminal.read)))))

  (fn parse-pattern [pattern]
    "Pretty hacky stuff going on here, but works for now."
    (local result {})
    (or
     (and (= "!" (char-at 1 pattern))
          (let [tk-key (string.sub pattern 2)]
            ;; this is a literal TK_* key
            (tset result :tk-key tk-key)
            true))
     (and (= "-" (char-at 2 pattern))
          (or
           (and (= "C" (char-at 1 pattern))
                (let [kbkey (char-at 3 pattern)]
                  (tset result :control true)
                  (tset result :tk-key (.. "TK_" (string.upper kbkey)))
                  true))))

     (let [kbkey (char-at 1 pattern)]
       (tset result :tk-key (.. "TK_" (string.upper kbkey))))
     )
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

  (when input
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
  )

  ;; return all data needed by the main loop.
  {:read input})
