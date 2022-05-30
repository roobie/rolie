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

(fn box [x1 y1 x2 y2]
  {:outer-x1 x1
   :outer-x2 x2
   :outer-y1 y1
   :outer-y2 y2
   :x1 (+ x1 1)
   :y1 (+ y1 1)
   :x2 (- x2 1)
   :y2 (- y2 1)
   :top-left {:x x1 :y y1}
   :bottom-right {:x x2 :y y2}
   :width (fn [box]
            (- (. box :x2) (. box :x1)))
   :height (fn [box]
             (- (. box :y2) (. box :y1)))
   })

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

(fn count-pattern [string-value pattern]
  "-- Equivalent lua function:
function count(base, pattern)
  return select(2, string.gsub(base, pattern, ""))
end"

  (select 2 (string.gsub string-value pattern "")))

(fn render-log-history [program box]
  ;; TODO: render multiline stuff accordingly.
  ;; As it stands, entries are overriden by entries below them.
  (local terminal program.terminal)

  (fn clean-string [str]
    "BearLibTerminal uses [ and ] for markup, so if we want to print them we
    have to double them."
    (-> str
        (string.gsub "%[" "%[%[")
        (string.gsub "%]" "%]%]")))

  (local height (box:height))
  (local width (box:width))
  (local top (. box :y1))
  (let [len (length program.log-history)
        boundary (math.min height len)]
    (var i 0)
    ;; (print (. box :y1) (. box :y2) height)
    (while (< i boundary)
      (local y (+ top i))
      (local entry (clean-string (. program.log-history (- len i))))
      (set i (+ i 1 (count-pattern entry "\n")))
      (when entry
        (terminal.print (. box :x1)
                            y
                            width
                            height
                            terminal.TK_ALIGN_DEFAULT
                            entry)))))

(fn render-input-handlers [program box]
  (local terminal program.terminal)

  (var i box.y1)
  (terminal.printf box.x1 i "Global handlers")
  (set i (+ 1 i))
  (each [_ spec (ipairs program.global-input-handlers)]
    (terminal.printf box.x1 i
                     (string.format "%s = %s" (or spec.friendly-pattern spec.pattern) spec.short-description))
    (set i (+ 1 i))))

(fn with-color [program color-fg func]
  (local terminal program.terminal)

  (local previous-color (terminal.state terminal.TK_COLOR))
  (terminal.color color-fg)
  (func program)
  (terminal.color previous-color))

(fn render-entities [program box]
  (local terminal program.terminal)

  (each [_ entity (ipairs program.entities)]
    (let [position (. entity :position)
          representation (. entity :representation)]
      (with-color program
       (terminal.color_from_name representation.color)
       (fn []
         (terminal.printf (+ box.x1 position.x)
                          (+ box.y1 position.y)
                          representation.glyph))))))

(fn layout []
  {:boxes {}
   :add-box (fn [self name box]
              (tset (. self :boxes) name box))
   :render-borders
   (fn [self program]
     (local terminal program.terminal)
     (local tw (terminal.state terminal.TK_WIDTH))
     (local th (terminal.state terminal.TK_HEIGHT))
     (local cache {})
     (each [name box (pairs (. self :boxes))]
       (for [dx 0 (+ 1 (box:width))]
         (terminal.printf (+ box.outer-x1 dx) box.outer-y1 "═")
         (terminal.printf (+ box.outer-x1 dx) box.outer-y2 "═"))
       (for [dy 0 (+ 1 (box:height))]
         (terminal.printf box.outer-x1 (+ box.outer-y1 dy) "║"))))
   })

;; exported
(fn renderer [program]
  (local terminal program.terminal)

  (local tw (terminal.state terminal.TK_WIDTH))
  (local th (terminal.state terminal.TK_HEIGHT))

  (terminal.clear)

  (local my-layout (layout))
  (my-layout:add-box :main (box -1 -1 (- tw 60) (- th 10)))
  (my-layout:add-box :botl (box -1 (- th 10) (- tw 60) th))
  (my-layout:add-box :topr (box (- tw 60) -1 tw (math.floor (/ th 2))))
  (my-layout:add-box :botr (box (- tw 60) (math.floor (/ th 2)) tw th))

  (tset program :layout my-layout)

  (my-layout:render-borders program)

  (render-log-history program
                      (. my-layout.boxes :botr))

  (render-input-handlers program
                         (. my-layout.boxes :topr))

  (render-entities program
                   (. my-layout.boxes :main))

  ;; Should be rendered last.
  (when program.show-mouse-cursor
    (render-mouse))
  (terminal.refresh)
  )
