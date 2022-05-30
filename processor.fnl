(fn make-entity-manager [program]
  (local entities program.entities)
  (var entity-counter 0)

  (fn id []
    (set entity-counter (+ 1 entity-counter))
    entity-counter)

  (fn index-of [entity-id]
    (var i 1)
    (var result nil)
    (while (<= i (length entities))
      (let [e (. entities i)]
        (when (= entity-id e.id)
          (set result i)
          (set i (length entities)))))
    result)

  (fn add-entity [entity]
    (tset entity :id (id))
    (table.insert entities entity))
  (fn remove-entity [entity-id]
    (local index (index-of entity-id))
    (when index
      (table.remove entities index)))

  {:add add-entity
   :remove remove-entity
   })

(var entity-manager nil)

(fn ai-processor [program entity]
  (when (> 0.04 (math.random))
    (tset entity.position :x (+ entity.position.x (* 1 (if (< 0.5 (math.random)) -1 1)))))
  (when (> 0.04 (math.random))
    (tset entity.position :y (+ entity.position.y (* 1 (if (< 0.5 (math.random)) -1 1)))))
  )

(fn processor [program]
  ;; just temp stuff
  (when (or (> program.step 0) (= program.step-once false))
    (tset program :process-count (+ 1 program.process-count))
    (set entity-manager (or entity-manager (make-entity-manager program)))
    (when (= nil (. program.entities 1))
      (entity-manager.add {:position {:x 3 :y 4}
                           :representation {:glyph "@" :color :white}
                           :ai {:name :random}})

      (entity-manager.add {:position {:x 13 :y 8}
                           :representation {:glyph "@" :color :red}
                           :ai {:name :random}})

      (entity-manager.add {:position {:x 13 :y 17}
                           :representation {:glyph "@" :color :octarine}
                           :ai {:name :random}})
      )

    (local terminal program.terminal)
    (tset program :entity-manager entity-manager)

    (each [_ e (ipairs program.entities)]
      (when e.ai
        (ai-processor program e)))))
