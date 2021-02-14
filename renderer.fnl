"
https://en.wikipedia.org/wiki/Block_Elements

U+2580 	▀ 	Upper half block
U+2581 	▁ 	Lower one eighth block
U+2582 	▂ 	Lower one quarter block
U+2583 	▃ 	Lower three eighths block
U+2584 	▄ 	Lower half block
U+2585 	▅ 	Lower five eighths block
U+2586 	▆ 	Lower three quarters block
U+2587 	▇ 	Lower seven eighths block
U+2588 	█ 	Full block
U+2589 	▉ 	Left seven eighths block
U+258A 	▊ 	Left three quarters block
U+258B 	▋ 	Left five eighths block
U+258C 	▌ 	Left half block
U+258D 	▍ 	Left three eighths block
U+258E 	▎ 	Left one quarter block
U+258F 	▏ 	Left one eighth block
U+2590 	▐ 	Right half block
U+2591 	░ 	Light shade
U+2592 	▒ 	Medium shade
U+2593 	▓ 	Dark shade
U+2594 	▔ 	Upper one eighth block
U+2595 	▕ 	Right one eighth block
U+2596 	▖ 	Quadrant lower left
U+2597 	▗ 	Quadrant lower right
U+2598 	▘ 	Quadrant upper left
U+2599 	▙ 	Quadrant upper left and lower left and lower right
U+259A 	▚ 	Quadrant upper left and lower right
U+259B 	▛ 	Quadrant upper left and upper right and lower left
U+259C 	▜ 	Quadrant upper left and upper right and lower right
U+259D 	▝ 	Quadrant upper right
U+259E 	▞ 	Quadrant upper right and lower left
U+259F 	▟ 	Quadrant upper right and lower left and lower right


---------------------------------------------------------------------
 	    	0 	1 	2 	3 	4 	5 	6 	7 	8 	9 	A 	B 	C 	D 	E 	F
---------------------------------------------------------------------
U+258x 	▀ 	▁ 	▂ 	▃ 	▄ 	▅ 	▆ 	▇ 	█ 	▉ 	▊ 	▋ 	▌ 	▍ 	▎ 	▏
---------------------------------------------------------------------
U+259x 	▐ 	░ 	▒ 	▓ 	▔ 	▕ 	▖ 	▗ 	▘ 	▙ 	▚ 	▛ 	▜ 	▝ 	▞ 	▟
---------------------------------------------------------------------

*********************************************************************
*********************************************************************

https://en.wikipedia.org/wiki/Box-drawing_character
      	0 	1 	2 	3 	4 	5 	6 	7 	8 	9 	A 	B 	C 	D 	E 	F
---------------------------------------------------------------------
U+250x 	─ 	━ 	│ 	┃ 	┄ 	┅ 	┆ 	┇ 	┈ 	┉ 	┊ 	┋ 	┌ 	┍ 	┎ 	┏
---------------------------------------------------------------------
U+251x 	┐ 	┑ 	┒ 	┓ 	└ 	┕ 	┖ 	┗ 	┘ 	┙ 	┚ 	┛ 	├ 	┝ 	┞ 	┟
---------------------------------------------------------------------
U+252x 	┠ 	┡ 	┢ 	┣ 	┤ 	┥ 	┦ 	┧ 	┨ 	┩ 	┪ 	┫ 	┬ 	┭ 	┮ 	┯
---------------------------------------------------------------------
U+253x 	┰ 	┱ 	┲ 	┳ 	┴ 	┵ 	┶ 	┷ 	┸ 	┹ 	┺ 	┻ 	┼ 	┽ 	┾ 	┿
---------------------------------------------------------------------
U+254x 	╀ 	╁ 	╂ 	╃ 	╄ 	╅ 	╆ 	╇ 	╈ 	╉ 	╊ 	╋ 	╌ 	╍ 	╎ 	╏
---------------------------------------------------------------------
U+255x 	═ 	║ 	╒ 	╓ 	╔ 	╕ 	╖ 	╗ 	╘ 	╙ 	╚ 	╛ 	╜ 	╝ 	╞ 	╟
---------------------------------------------------------------------
U+256x 	╠ 	╡ 	╢ 	╣ 	╤ 	╥ 	╦ 	╧ 	╨ 	╩ 	╪ 	╫ 	╬ 	╭ 	╮ 	╯
---------------------------------------------------------------------
U+257x 	╰ 	╱ 	╲ 	╳ 	╴ 	╵ 	╶ 	╷ 	╸ 	╹ 	╺ 	╻ 	╼ 	╽ 	╾ 	╿
---------------------------------------------------------------------

"

(fn render-mouse [program]
  (local terminal program.terminal)
  (local mx (terminal.state terminal.TK_MOUSE_X))
  (local my (terminal.state terminal.TK_MOUSE_Y))
  (local block "┏")

  (local previous-color (terminal.state terminal.TK_COLOR))
  ;; (local previous-color (terminal.color_from_name "white"))
  (local temp-color (terminal.color_from_argb 255 127 127 127))
  (terminal.color temp-color)
  (terminal.printf mx my block)
  (terminal.color previous-color))

(fn render-log-history [program]
  (local terminal program.terminal)
  (local tw (terminal.state terminal.TK_WIDTH))
  (local th (terminal.state terminal.TK_HEIGHT))

  (fn repeat [times char]
    (var result "")
    (for [i 0 times 1]
      (set result (.. result char)))
    result)
  (local height 7)
  (local top (- th height))
  (terminal.printf 0 top (repeat tw "═"))
  (let [len (length program.log-history)]
    (for [i 0 (math.min (- height 1) len)]
      (local y (+ 1 top i))
      (local entry (. program.log-history (- len i)))
      (when entry
        (terminal.printf 0 y entry)))))

;; exported
(fn renderer [program]
  (local terminal program.terminal)

  (local tw (terminal.state terminal.TK_WIDTH))
  (local th (terminal.state terminal.TK_HEIGHT))

  (terminal.clear)

  (terminal.printf 2 1 "World!")

  (render-log-history program)

  ;; Should be rendered last.
  (when program.show-cursor
    (render-mouse))
  (terminal.refresh)
  )
